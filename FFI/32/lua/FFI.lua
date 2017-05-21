local ffi = require('ffi')
local FFIdir = [[..\]]--[[E:\Programs\Mathematica\FFI\]]
local libFFI = ffi.load(FFIdir..'ffi.dll')
ffi.cdef[[
int FFI_Open(int size);
void FFI_Mode(int vm, int mode);
void FFI_Close(int vm);
void FFI_Reset(int vm);
void FFI_PutInteger32(int vm, int arg);
void FFI_PutInteger64(int vm, long long arg);
void FFI_PutReal32(int vm, float arg);
void FFI_PutReal64(int vm, double arg);
int FFI_GetInteger32(int vm, void* addr);
long long FFI_GetInteger64(int vm, void* addr);
float FFI_GetReal32(int vm, void* addr);
double FFI_GetReal64(int vm, void* addr);
int FFI_Load(const char* path);
void FFI_Free(int handle);
int FFI_Find(int handle, const char* symbol);
//void FFI_VApply(int vm, void* result, void* addr, const char* signature, va_list args);
//void FFI_Apply(int vm, void* result, void* addr, const char* signature, ...);
]]
FFI = {}
FFI.open = libFFI.FFI_Open
FFI.mode = libFFI.FFI_Mode
FFI.close = libFFI.FFI_Close
FFI.reset = libFFI.FFI_Reset
FFI.load = libFFI.FFI_Load
FFI.free = libFFI.FFI_Free
FFI.find = libFFI.FFI_Find
FFI.call = 
function (addr, signature, ...)
    local vm = FFI.vm
    --local vm = FFI.open(256)
    --FFI.mode(vm, 0)
    FFI.reset(vm)
    local args = {...}
    for i = 1, #signature - 2 do
        local atype = signature:sub(i, i)
        if atype == 'i' then
            libFFI.FFI_PutInteger32(vm, args[i])
        elseif atype == 'l' then
            libFFI.FFI_PutInteger64(vm, args[i])
        elseif atype == 'f' then
            libFFI.FFI_PutReal32(vm, args[i])
        elseif atype == 'd' then
            libFFI.FFI_PutReal64(vm, args[i])
        end
    end
    local result
    local rtype = signature:sub(-1)
    if rtype == 'i' then
        result = libFFI.FFI_GetInteger32(vm, addr)
    elseif rtype == 'l' then
        result = libFFI.FFI_GetInteger64(vm, addr)
    elseif rtype == 'f' then
        result = libFFI.FFI_GetReal32(vm, addr)
    elseif rtype == 'd' then
        result = libFFI.FFI_GetReal64(vm, addr)
    end
    --FFI.close(vm)
    return result
end
FFI.vm = FFI.open(4096)
FFI.mode(FFI.vm, 0)
return FFI
