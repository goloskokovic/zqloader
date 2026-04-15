//==============================================================================
// PROJECT:         zqloader
// FILE:            zqloader_ffi.cpp
// DESCRIPTION:     C FFI wrapper for zqloader C++ library for Flutter integration
// 
// Copyright (c) 2024 Daan Scherft [Oxidaan]
// This project uses the MIT license. See LICENSE.txt for details.
//==============================================================================

#include "zqloader.h"
#include "memoryblock.h"
#include <cstring>
#include <map>
#include <mutex>

// Export C functions for FFI
extern "C" {

// Handle to ZQLoader instance (opaque pointer)
typedef void* ZQLoaderHandle;

// Storage for ZQLoader instances
static std::map<int64_t, std::unique_ptr<ZQLoader>> g_loaders;
static std::mutex g_loaders_mutex;
static int64_t g_next_handle_id = 1;

// Allocate a new ZQLoader instance
int64_t zqloader_create() {
    std::lock_guard<std::mutex> lock(g_loaders_mutex);
    int64_t handle = g_next_handle_id++;
    g_loaders[handle] = std::make_unique<ZQLoader>();
    return handle;
}

// Free a ZQLoader instance
void zqloader_destroy(int64_t handle) {
    std::lock_guard<std::mutex> lock(g_loaders_mutex);
    g_loaders.erase(handle);
}

// Helper to get loader from handle
static ZQLoader* get_loader(int64_t handle) {
    auto it = g_loaders.find(handle);
    if (it != g_loaders.end()) {
        return it->second.get();
    }
    return nullptr;
}

// Get version string
const char* zqloader_get_version() {
    return GetVersion();
}

// Set normal filename for loading
int zqloader_set_normal_filename(int64_t handle, const char* filename, const char* zxfilename) {
    auto loader = get_loader(handle);
    if (!loader) return 0;
    try {
        loader->SetNormalFilename(
            std::filesystem::path(filename),
            zxfilename ? std::string(zxfilename) : ""
        );
        return 1;
    } catch (...) {
        return 0;
    }
}

// Set turbo filename for loading
int zqloader_set_turbo_filename(int64_t handle, const char* filename, const char* zxfilename) {
    auto loader = get_loader(handle);
    if (!loader) return 0;
    try {
        loader->SetTurboFilename(
            std::filesystem::path(filename),
            zxfilename ? std::string(zxfilename) : ""
        );
        return 1;
    } catch (...) {
        return 0;
    }
}

// Set output filename and allow overwrite
int zqloader_set_output_filename(int64_t handle, const char* filename, int allow_overwrite) {
    auto loader = get_loader(handle);
    if (!loader) return 0;
    try {
        loader->SetOutputFilename(
            std::filesystem::path(filename),
            allow_overwrite != 0
        );
        return 1;
    } catch (...) {
        return 0;
    }
}

// Set volume for left and right channels
int zqloader_set_volume(int64_t handle, int volume_left, int volume_right) {
    auto loader = get_loader(handle);
    if (!loader) return 0;
    try {
        loader->SetVolume(volume_left, volume_right);
        return 1;
    } catch (...) {
        return 0;
    }
}

// Set sample rate (0 = device default)
int zqloader_set_sample_rate(int64_t handle, uint32_t sample_rate) {
    auto loader = get_loader(handle);
    if (!loader) return 0;
    try {
        loader->SetSampleRate(sample_rate);
        return 1;
    } catch (...) {
        return 0;
    }
}

// Set bit loop max
int zqloader_set_bit_loop_max(int64_t handle, int value) {
    auto loader = get_loader(handle);
    if (!loader) return 0;
    try {
        loader->SetBitLoopMax(value);
        return 1;
    } catch (...) {
        return 0;
    }
}

// Set zero max
int zqloader_set_zero_max(int64_t handle, int value) {
    auto loader = get_loader(handle);
    if (!loader) return 0;
    try {
        loader->SetZeroMax(value);
        return 1;
    } catch (...) {
        return 0;
    }
}

// Set durations
int zqloader_set_durations(int64_t handle, int zero_duration, int one_duration, int end_of_byte_delay) {
    auto loader = get_loader(handle);
    if (!loader) return 0;
    try {
        loader->SetDurations(zero_duration, one_duration, end_of_byte_delay);
        return 1;
    } catch (...) {
        return 0;
    }
}

// Set IO values
int zqloader_set_io_values(int64_t handle, int io_init_value, int io_xor_value) {
    auto loader = get_loader(handle);
    if (!loader) return 0;
    try {
        loader->SetIoValues(io_init_value, io_xor_value);
        return 1;
    } catch (...) {
        return 0;
    }
}

// Set compression type (0=none, 1=rle, 2=automatic)
int zqloader_set_compression_type(int64_t handle, int compression_type) {
    auto loader = get_loader(handle);
    if (!loader) return 0;
    try {
        loader->SetCompressionType(static_cast<CompressionType>(compression_type));
        return 1;
    } catch (...) {
        return 0;
    }
}

// Set decompression speed
int zqloader_set_decompression_speed(int64_t handle, int kb_per_sec) {
    auto loader = get_loader(handle);
    if (!loader) return 0;
    try {
        loader->SetDeCompressionSpeed(kb_per_sec);
        return 1;
    } catch (...) {
        return 0;
    }
}

// Set initial wait in milliseconds
int zqloader_set_initial_wait(int64_t handle, uint32_t milliseconds) {
    auto loader = get_loader(handle);
    if (!loader) return 0;
    try {
        loader->SetInitialWait(std::chrono::milliseconds(milliseconds));
        return 1;
    } catch (...) {
        return 0;
    }
}

// Set spectrum clock frequency in hz
int zqloader_set_spectrum_clock(int64_t handle, int spectrum_clock) {
    auto loader = get_loader(handle);
    if (!loader) return 0;
    try {
        loader->SetSpectrumClock(spectrum_clock);
        return 1;
    } catch (...) {
        return 0;
    }
}

// Set use standard speed for ROM
int zqloader_set_use_standard_speed_for_rom(int64_t handle, int to_what) {
    auto loader = get_loader(handle);
    if (!loader) return 0;
    try {
        loader->SetUseStandaardSpeedForRom(to_what != 0);
        return 1;
    } catch (...) {
        return 0;
    }
}

// Set action (0=play_audio, 1=write_wav, 2=write_tzx)
int zqloader_set_action(int64_t handle, int action) {
    auto loader = get_loader(handle);
    if (!loader) return 0;
    try {
        loader->SetAction(static_cast<ZQLoader::Action>(action));
        return 1;
    } catch (...) {
        return 0;
    }
}

// Set loader copy target address
int zqloader_set_loader_copy_target(int64_t handle, uint16_t address) {
    auto loader = get_loader(handle);
    if (!loader) return 0;
    try {
        loader->SetLoaderCopyTarget(address);
        return 1;
    } catch (...) {
        return 0;
    }
}

// Set fun attributes
int zqloader_set_fun_attribs(int64_t handle, int value) {
    auto loader = get_loader(handle);
    if (!loader) return 0;
    try {
        loader->SetFunAttribs(value != 0);
        return 1;
    } catch (...) {
        return 0;
    }
}

// Set when done behavior
int zqloader_set_when_done_do(int64_t handle, uint16_t usr_address, int return_to_basic) {
    auto loader = get_loader(handle);
    if (!loader) return 0;
    try {
        loader->SetWhenDoneDo(usr_address, return_to_basic != 0);
        return 1;
    } catch (...) {
        return 0;
    }
}

// Reset loader
int zqloader_reset(int64_t handle) {
    auto loader = get_loader(handle);
    if (!loader) return 0;
    try {
        loader->Reset();
        return 1;
    } catch (...) {
        return 0;
    }
}

// Run synchronously
int zqloader_run(int64_t handle) {
    auto loader = get_loader(handle);
    if (!loader) return 0;
    try {
        loader->Run();
        return 1;
    } catch (...) {
        return 0;
    }
}

// Start asynchronously
int zqloader_start(int64_t handle) {
    auto loader = get_loader(handle);
    if (!loader) return 0;
    try {
        loader->Start();
        return 1;
    } catch (...) {
        return 0;
    }
}

// Stop loading
int zqloader_stop(int64_t handle) {
    auto loader = get_loader(handle);
    if (!loader) return 0;
    try {
        loader->Stop();
        return 1;
    } catch (...) {
        return 0;
    }
}

// Wait until done
int zqloader_wait_until_done(int64_t handle) {
    auto loader = get_loader(handle);
    if (!loader) return 0;
    try {
        loader->WaitUntilDone();
        return 1;
    } catch (...) {
        return 0;
    }
}

// Check if busy
int zqloader_is_busy(int64_t handle) {
    auto loader = get_loader(handle);
    if (!loader) return 0;
    return loader->IsBusy() ? 1 : 0;
}

// Set preload
int zqloader_set_preload(int64_t handle) {
    auto loader = get_loader(handle);
    if (!loader) return 0;
    try {
        loader->SetPreload();
        return 1;
    } catch (...) {
        return 0;
    }
}

// Is preloaded
int zqloader_is_preloaded(int64_t handle) {
    auto loader = get_loader(handle);
    if (!loader) return 0;
    return loader->IsPreLoaded() ? 1 : 0;
}

// Play leader tone
int zqloader_play_leader_tone(int64_t handle) {
    auto loader = get_loader(handle);
    if (!loader) return 0;
    try {
        loader->PlayleaderTone();
        return 1;
    } catch (...) {
        return 0;
    }
}

// Get time needed in milliseconds
uint64_t zqloader_get_time_needed(int64_t handle) {
    auto loader = get_loader(handle);
    if (!loader) return 0;
    return loader->GetTimeNeeded().count();
}

// Get current time in milliseconds
uint64_t zqloader_get_current_time(int64_t handle) {
    auto loader = get_loader(handle);
    if (!loader) return 0;
    return loader->GetCurrentTime().count();
}

// Get estimated duration in milliseconds
uint64_t zqloader_get_estimated_duration(int64_t handle) {
    auto loader = get_loader(handle);
    if (!loader) return 0;
    return loader->GetEstimatedDuration().count();
}

// Get duration in TStates
int zqloader_get_duration_in_tstates(int64_t handle) {
    auto loader = get_loader(handle);
    if (!loader) return 0;
    return loader->GetDurationInTStates();
}

// Set exe filename
int zqloader_set_exe_filename(int64_t handle, const char* filename) {
    auto loader = get_loader(handle);
    if (!loader) return 0;
    try {
        loader->SetExeFilename(std::filesystem::path(filename));
        return 1;
    } catch (...) {
        return 0;
    }
}

// Get device sample rate
uint32_t zqloader_get_device_sample_rate(int64_t handle) {
    auto loader = get_loader(handle);
    if (!loader) return 0;
    return loader->GetDeviceSampleRate();
}

// Check if file is zqloader.tap
int zqloader_file_is_zqloader(const char* filename) {
    try {
        return ZQLoader::FileIsZqLoader(std::filesystem::path(filename)) ? 1 : 0;
    } catch (...) {
        return 0;
    }
}

} // extern "C"
