cmake_minimum_required(VERSION 3.12)

add_executable(mktexfmt
    mktexfmt.c
)
add_executable(mktexlsr
    dirutil.c
    mkpaths.c
    mktex.h
    mktexlsr.c
)
add_executable(mktexmf
    dirutil.c
    getdestdir.c
    mkpaths.c
    mktex.h
    mktexmf.c
    mktexupd.c
)
add_executable(mktexpk
    dirutil.c
    getdestdir.c
    mkpaths.c
    mktex.h
    mktexpk.c
    mktexupd.c
)
add_executable(mktextfm
    dirutil.c
    getdestdir.c
    mkpaths.c
    mktex.h
    mktextfm.c
    mktexupd.c
)
add_executable(mktexupd
    mkpaths.c
    mktex.h
    mktexupdmain.c
    mktexupd.c
)

target_link_libraries(mktexfmt kpathsea)
target_link_libraries(mktexlsr kpathsea)
target_link_libraries(mktexmf kpathsea)
target_link_libraries(mktexpk kpathsea)
target_link_libraries(mktextfm kpathsea)
target_link_libraries(mktexupd kpathsea)
