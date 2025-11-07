cmake_minimum_required(VERSION 3.10)
project(EthereumCrypto)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Find OpenSSL
find_package(OpenSSL REQUIRED)

# Add executable
add_executable(crypto keccak256.cpp)

# Link OpenSSL
target_link_libraries(crypto OpenSSL::SSL OpenSSL::Crypto)

# Compiler warnings
if(MSVC)
    target_compile_options(crypto PRIVATE /W4)
else()
    target_compile_options(crypto PRIVATE -Wall -Wextra -Wpedantic)
endif()
