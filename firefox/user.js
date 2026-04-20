// Wayland / PipeWire screencast hardening for Firefox under sway.
//
// All of these are the FF 149 defaults but we lock them so that a future
// upgrade or about:config tweak cannot accidentally drop us back to the
// X11/XWayland code path (which freezes within seconds on wlroots).

// Use the PipeWire portal for getDisplayMedia / WebRTC screen sharing.
user_pref("media.webrtc.camera.allow-pipewire",  true);
user_pref("media.webrtc.capture.allow-pipewire", true);

// Force xdg-desktop-portal for media device requests (no ALSA/PulseAudio
// poking through XWayland fallbacks).
user_pref("media.devices.enumerate.legacy.enabled", false);

// Hardware video decode via VA-API on amdgpu/intel — keeps screencast frame
// pacing smooth when the same GPU is also encoding the share.
user_pref("media.ffmpeg.vaapi.enabled",                true);
user_pref("media.ffvpx.enabled",                       false);
user_pref("media.rdd-ffmpeg.enabled",                  true);
user_pref("media.av1.enabled",                         true);
user_pref("media.hardware-video-decoding.force-enabled", true);

// Enable Wayland renderer (default true since FF 121 but explicit here).
user_pref("widget.wayland.dmabuf-textures.enabled",    true);
user_pref("gfx.x11-egl.force-enabled",                 false);

// Disable touch-screen "scroll on touch" hijacks of right-click menu in
// share-prompt dialogs (long-standing UX wart).
user_pref("dom.w3c_touch_events.enabled",              0);
