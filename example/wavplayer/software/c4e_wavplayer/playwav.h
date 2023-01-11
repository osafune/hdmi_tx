/* WAVファイル再生 */

#include <alt_types.h>

// ペリフェラル初期化 
int play_init(void);

// 再生ステータス取得 
int play_status(void);
alt_u32 play_getbuffdata(int buffpos);

// 再生停止 
int play_stop(void);

// WAVファイル再生開始 
int play_wav(const char *wavname);

// 音量設定 
int play_setvol(int vol_l, int vol_r);

