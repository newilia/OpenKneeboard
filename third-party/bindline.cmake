# Copyright (C) 2024 Fred Emmott <fred@fredemmott.com>
# SPDX-License-Identifier: MIT
include(FetchContent)
scoped_include("cppwinrt.cmake")
scoped_include("wil.cmake")

FetchContent_Declare(
    bindline
    URL "https://github.com/fredemmott/bindline/archive/refs/tags/v0.1.zip"
    URL_HASH "SHA256=765a1a5251d7901a99cc6663fe08cb751c09deca6740ed99b2d964d0af8ccbc6"
    EXCLUDE_FROM_ALL
)
FetchContent_MakeAvailable(bindline)

# Apply compatibility patches for MSVC C++23
if(EXISTS "${bindline_SOURCE_DIR}/include/FredEmmott/cppwinrt/detail/context_binder.hpp")
    file(READ "${bindline_SOURCE_DIR}/include/FredEmmott/cppwinrt/detail/context_binder.hpp" CONTEXT_BINDER_CONTENT)
    string(REPLACE 
        "static_assert(false, \"Don't know how to invoke in supplied context\");"
        "static_assert(sizeof(TContext) == 0, \"Don't know how to invoke in supplied context\");"
        CONTEXT_BINDER_CONTENT_FIXED "${CONTEXT_BINDER_CONTENT}")
    file(WRITE "${bindline_SOURCE_DIR}/include/FredEmmott/cppwinrt/detail/context_binder.hpp" "${CONTEXT_BINDER_CONTENT_FIXED}")
endif()

# Create config tweaks file to disable problematic static_assert(false) in traced_bindline.hpp
file(WRITE "${bindline_SOURCE_DIR}/include/FredEmmott.bindline.config-tweaks.hpp" 
"// Copyright (C) 2024 Fred Emmott <fred@fredemmott.com>
// SPDX-License-Identifier: MIT
#pragma once

// Disable static_assert(false) in if constexpr branches for MSVC compatibility
// This is a workaround for bindline v0.1 compatibility with certain MSVC versions
#define FREDEMMOTT_BINDLINE_CAN_STATIC_ASSERT_FALSE false
")

add_library(bindline_unified INTERFACE)
target_link_libraries(
    bindline_unified
    INTERFACE
    FredEmmott::bindline
    FredEmmott::cppwinrt
    FredEmmott::weak_refs
    ThirdParty::CppWinRT
    ThirdParty::WIL
)

add_library(ThirdParty::bindline ALIAS bindline_unified)

include(ok_add_license_file)
ok_add_license_file("${bindline_SOURCE_DIR}/LICENSE" "LICENSE-ThirdParty-bindline.txt")