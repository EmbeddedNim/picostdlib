
# hide a warning in lwip
set_source_files_properties(
  "${PICO_LWIP_PATH}/src/apps/altcp_tls/altcp_tls_mbedtls.c"
  PROPERTIES COMPILE_OPTIONS "-Wno-unused-result"
)

# Get the Nim include path to get nimbase.h
execute_process(
  COMMAND nim dump --dump.format:json --hints:off -
  OUTPUT_VARIABLE NIM_DUMP_JSON
  OUTPUT_STRIP_TRAILING_WHITESPACE
)
string(JSON NIM_LIB_DIR GET "${NIM_DUMP_JSON}" libpath)

set(NIMCACHE_DIR "${CMAKE_BINARY_DIR}/nimcache")
set(NIMCACHE_JSON_FILE "${NIMCACHE_DIR}/${OUTPUT_NAME}.cached.json")
set_directory_properties(PROPERTIES CMAKE_CONFIGURE_DEPENDS ${NIMCACHE_JSON_FILE})

if(EXISTS ${NIMCACHE_JSON_FILE})
  # Read the nimcache JSON file to get the source files
  set(NimSources "")
  file(READ "${NIMCACHE_JSON_FILE}" NIMCACHE_JSON_DATA)
  if(NIMCACHE_JSON_DATA)
    string(JSON cfilelength LENGTH "${NIMCACHE_JSON_DATA}" compile)
    math(EXPR cfilelength "${cfilelength} - 1")
    foreach(IDX RANGE ${cfilelength})
        string(JSON CUR_FILE GET "${NIMCACHE_JSON_DATA}" compile ${IDX} 0)
        string(REPLACE "\\" "/" CUR_FILE "${CUR_FILE}")
        list(APPEND NimSources ${CUR_FILE})
    endforeach()
  endif()
  # Suppress gcc warnings for nim-generated files
  set_source_files_properties(${NimSources} PROPERTIES COMPILE_OPTIONS "-w")
endif()

set(PICOSTDLIB_IMPORTS_PATH ${CMAKE_CURRENT_BINARY_DIR}/picostdlib/imports.cmake)

function(picostdlib_configure name)
  target_include_directories(${name} PRIVATE
    ${NIM_LIB_DIR}
  )

  if(EXISTS ${PICOSTDLIB_IMPORTS_PATH})
    include(${PICOSTDLIB_IMPORTS_PATH}) # Include our generated file
    link_imported_libs(${name}) # call our generated function to import all pico-sdk libs we're using
  else()
    # fallback to something
    target_link_libraries(${name} pico_stdlib)
  endif()
endfunction()
