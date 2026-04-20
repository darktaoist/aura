const kR2BaseUrl = 'https://pub-96de8159f4e24bd5ba7aeb7ddafd2850.r2.dev';

const kE2bFileName    = 'gemma-4-E2B-it.litertlm';
const kE4bFileName    = 'gemma-4-E4B-it.litertlm';
const kE2bDownloadUrl = '$kR2BaseUrl/$kE2bFileName';
const kE4bDownloadUrl = '$kR2BaseUrl/$kE4bFileName';

/// 예상 파일 크기 (바이트) — 95% 이상이면 유효로 판정
const kE2bExpectedBytes = 2583085056;
const kE4bExpectedBytes = 3654467584;
