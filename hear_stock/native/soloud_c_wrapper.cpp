#pragma message("✅ 컴파일 중: soloud_c_wrapper.cpp")
#include "soloud.h"
#include "soloud_wav.h"


extern "C" {
  static SoLoud::Soloud soloud;
  static SoLoud::Wav wav;

  void init_soloud() {
    soloud.init();
    wav.load("sample3.wav");
  }

  void play3d(float x, float y, float z) {
    soloud.play3d(wav, x, y, z);
    soloud.set3dListenerParameters(
      0.0f, 0.0f, 0.0f,   // 위치 (x, y, z)
      0.0f, 0.0f, -1.0f,  // 바라보는 방향 (at vector)
      0.0f, 1.0f, 0.0f,   // 위쪽 방향 (up vector)
      0.0f, 0.0f, 0.0f    // 속도 (velocity vector)
  );
  
  soloud.update3dAudio();
  }

  void stop_soloud() {
    soloud.deinit();
  }
}
