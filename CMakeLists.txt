# ==============================================================================
# PROJECT:         zqloader
# FILE:            CMakeLists.txt
# DESCRIPTION:     CMake Project for zqloader
#
# Copyright (c) 2024 Daan Scherft [Oxidaan]
# This project uses the MIT license. See LICENSE.txt for details.
# ==============================================================================
# Main zqloader
# defines targets for zqloaderlib and zqloader (console) application
# includes zqloaderui and the z80 sjasmplus subdirecory projects

cmake_minimum_required(VERSION 3.21)

# Android configuration
if(NOT CMAKE_SYSTEM_NAME)
    set(CMAKE_SYSTEM_NAME Android)
endif()

# Set Android NDK if needed
if(ANDROID)
    message(STATUS "Building for Android API Level: ${ANDROID_PLATFORM}")
    message(STATUS "Android ABI: ${ANDROID_ABI}")
endif()

project(zqloader VERSION 2.0.0 LANGUAGES CXX)

add_subdirectory(z80)

set(TARGET_LIB ${PROJECT_NAME}lib)
set(TARGET_EXE ${PROJECT_NAME})

file(GLOB INCLUDE
    "zqloader/*.h"
    "*.h"
    )


set(SOURCE_LIB
    z80snapshot_loader.cpp
    datablock.cpp
    enumstreamer.cpp
    miniaudio.cpp
    samplesender.cpp
    spectrum_loader.cpp
    symbols.cpp
    taploader.cpp
    taptoturboblocks.cpp
    test.cpp
    tools.cpp
    turboblocks.cpp
    turboblock.cpp
    tzxloader.cpp
    tzxwriter.cpp
    sampletowav.cpp
    pulsers.cpp
    zqloader.cpp

)


set(DOCUMENTATION
    README.md
    LICENSE.txt
)    


# Common library containing bulk of code
add_library(${TARGET_LIB} SHARED  ${SOURCE_LIB} ${INCLUDE} ${DOCUMENTATION} )

# We need c++17
target_compile_features(${TARGET_LIB} PUBLIC cxx_std_17)


# Here lives miniadio.h
target_include_directories(${TARGET_LIB} PRIVATE miniaudio)


target_compile_definitions(${TARGET_LIB} PUBLIC
    "NDEBUG;"
    "_CONSOLE;"
    "UNICODE;"
    "_UNICODE"
    "LIB_BUILD"
)


if (CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
    set(GCC true)
endif()

if(MSVC)
    target_compile_options(${TARGET_LIB} PUBLIC
        /permissive-;
        /MP;                # multi processor build
        /Oi;                # intrincic functions
        /Gy;                # function level linking
        /W4;                # warning level
        /WX;                # warnings are errors
        ${DEFAULT_CXX_DEBUG_INFORMATION_FORMAT};
        /Zc:__cplusplus;    # fix bug to recognise __cplusplus
        ${DEFAULT_CXX_EXCEPTION_HANDLING}
    )
    target_link_options(${TARGET_LIB} PUBLIC
        /DEBUG;
        /SUBSYSTEM:CONSOLE;
        /OPT:REF;           # Remove unreferenced
        /OPT:ICF            # identical COMDAT folding
    )
endif()

if (GCC) 
    target_compile_options(${TARGET_LIB} PUBLIC 
        -Wall 
        -pedantic
        -Werror
        -Wno-error=deprecated-declarations
        -Wno-sign-compare
    )
endif()

# Android specific configuration
if(ANDROID)
    target_compile_options(${TARGET_LIB} PUBLIC
        -fPIC
        -fno-limit-debug-info
    )
    # Suppress some warnings for Android NDK
    target_compile_options(${TARGET_LIB} PUBLIC
        -Wno-error=format-security
        -Wno-error=uninitialized
    )
endif()


if(UNIX AND NOT ANDROID)
    target_link_libraries(${TARGET_LIB} PRIVATE dl pthread)
endif()

if(ANDROID)
    # Android uses bionic libc (no separate libdl needed in newer NDKs)
    target_link_libraries(${TARGET_LIB} PRIVATE log)
    # Enable shared library build for Android
    set_target_properties(${TARGET_LIB} PROPERTIES
        SOVERSION 1
    )
endif()

if(WIN32)
    target_link_libraries(${TARGET_LIB} PRIVATE ws2_32 DbgHelp psapi)
endif()

# include ui/qt application
add_subdirectory(zqloaderui)

# commandline/console application (not typically used on Android)
if(NOT ANDROID)
    set(SOURCE_EXE main.cpp)

    if(MSVC)
        set(SOURCE_EXE ${SOURCE_EXE}
        resource/zqloader.rc)
    endif()

    # The console application
    add_executable(${TARGET_EXE}  ${SOURCE_EXE}  )
    target_link_libraries(${TARGET_EXE} ${TARGET_LIB})
endif()


#installation
include(GNUInstallDirs)

if(ANDROID)
    # Android installation - libraries go to lib directory
    install(TARGETS ${TARGET_LIB}
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    )
else()
    install(TARGETS ${TARGET_EXE} ${TARGET_LIB}
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    )
endif()

