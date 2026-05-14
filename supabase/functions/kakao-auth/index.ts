import { createClient } from 'jsr:@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    const { access_token } = await req.json();
    if (!access_token) {
      return new Response(JSON.stringify({ error: 'access_token required' }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    // 1. 카카오 사용자 정보 조회
    const kakaoRes = await fetch('https://kapi.kakao.com/v2/user/me', {
      headers: { Authorization: `Bearer ${access_token}` },
    });

    if (!kakaoRes.ok) {
      return new Response(JSON.stringify({ error: 'Kakao token invalid' }), {
        status: 401,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const kakaoUser = await kakaoRes.json();
    const kakaoId = String(kakaoUser.id);
    const nickname = kakaoUser.kakao_account?.profile?.nickname ?? '사용자';
    const email = `kakao_${kakaoId}@aura.kakao`;

    // 2. Supabase admin client
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!,
      { auth: { autoRefreshToken: false, persistSession: false } },
    );

    // 3. 사용자 upsert: createUser 시도 → 이미 존재하면 무시
    const { data: created, error: createErr } = await supabase.auth.admin.createUser({
      email,
      email_confirm: true,
      user_metadata: { full_name: nickname, provider: 'kakao', kakao_id: kakaoId },
    });

    if (createErr) {
      // 이메일 중복 에러(422)는 정상 — 기존 유저로 계속 진행
      const isDuplicate =
        createErr.status === 422 ||
        createErr.message.toLowerCase().includes('already') ||
        createErr.message.toLowerCase().includes('registered');
      if (!isDuplicate) throw createErr;
    }

    // 신규 유저인 경우에만 프로필 생성
    if (created?.user) {
      await supabase.from('profiles').upsert(
        { id: created.user.id, display_name: nickname },
        { onConflict: 'id' },
      );
    }

    // 4. 세션 토큰 발급: generateLink → email_otp → Flutter verifyOTP
    const { data: linkData, error: linkErr } = await supabase.auth.admin.generateLink({
      type: 'magiclink',
      email,
    });

    if (linkErr || !linkData?.properties) {
      throw linkErr ?? new Error('Failed to generate magic link');
    }

    return new Response(
      JSON.stringify({
        email,
        token: linkData.properties.email_otp,
      }),
      {
        status: 200,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      },
    );
  } catch (e) {
    console.error('[kakao-auth]', e);
    return new Response(JSON.stringify({ error: String(e) }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});
