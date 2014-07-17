#include <zlib/zlib.h>
#include <string.h>

#include "alignment.h"

namespace nvbio {
namespace spp {

AlignmentStream* open_bam_file(const char* file_name);

AlignmentStream* open_alignment_file(const char* file_name)
{
    if (strcmp( file_name + strlen(file_name) - 4u, ".bam" ) == 0)
        return open_bam_file( file_name );

    return NULL;
}

} // spp namespace
} // nvbio namespace
