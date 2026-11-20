import ctypes, sys

dll = ctypes.CDLL(sys.argv[1] if len(sys.argv) > 1 else "libmpv-2.dll")
dll.mpv_client_api_version.restype = ctypes.c_ulong
v = dll.mpv_client_api_version()
major, minor = v >> 16, v & 0xFFFF
print(f"MPV_CLIENT_API_VERSION = {major}.{minor}")
assert (major, minor) >= (2, 0), "unexpected client API version"
print("smoke test OK")
