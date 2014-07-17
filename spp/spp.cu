/******************************************************************************
  spp.cpp

  (c) 2014 - Nikhil R Podduturi
  Cherry Lab, Stanford University

  Licensed under the GNU General Public License 2.0 license.
 ******************************************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include <nvbio/basic/timer.h>
#include <nvbio/basic/console.h>
#include <nvbio/basic/shared_pointer.h>
#include <nvbio/io/fmindex/fmindex.h>

#include "alignment.h"

void crcInit();

using namespace nvbio;
using namespace spp;

int main(int argc, char* argv[])
{
    Timer timer;
    timer.start();

    cudaSetDeviceFlags( cudaDeviceMapHost | cudaDeviceLmemResizeToMax );

    crcInit();
    if (argc == 1 ||
        (argc == 2 && strcmp( argv[1], "--help" ) == 0) ||
        (argc == 2 && strcmp( argv[1], "-h" ) == 0))
    {
        log_info(stderr,"idr [options] -- bam1 bam2\n");
        exit(0);
    }

    //bool   debug      = false;
    int cuda_device  = -1;
    int device_count;
    cudaGetDeviceCount(&device_count);
    log_verbose(stderr, "  cuda devices : %d\n", device_count);

    // inspect and select cuda devices
    if (device_count)
    {
        if (cuda_device == -1)
        {
            int            best_device = 0;
            cudaDeviceProp best_device_prop;
            cudaGetDeviceProperties( &best_device_prop, best_device );
            for (int device = 0; device < device_count; ++device)
            {
                cudaDeviceProp device_prop;
                cudaGetDeviceProperties( &device_prop, device );
                if (device_prop.major >= best_device_prop.major &&
                    device_prop.minor >= best_device_prop.minor)
                {
                    best_device_prop = device_prop;
                    best_device      = device;
                }
            }
            cuda_device = best_device;
        }
        log_verbose(stderr, "  chosen device %d\n", cuda_device);
        {
            cudaDeviceProp device_prop;
            cudaGetDeviceProperties( &device_prop, cuda_device );
            log_verbose(stderr, "    device name        : %s\n", device_prop.name);
            log_verbose(stderr, "    compute capability : %d.%d\n", device_prop.major, device_prop.minor);
        }
        cudaSetDevice( cuda_device );
    }

    int arg = 1;
    try
    {
        if (argc == arg + 2)
        {
            const char *aln_file_nameL = argv[arg];
            const char *aln_file_nameR = argv[arg+1];

            SharedPointer<AlignmentStream> aln_streamL = SharedPointer<AlignmentStream>( open_alignment_file( aln_file_nameL ) );
            SharedPointer<AlignmentStream> aln_streamR = SharedPointer<AlignmentStream>( open_alignment_file( aln_file_nameR ) );

            printf("I'm here");

            if (aln_streamL == NULL || aln_streamL->is_ok() == false)
            {
                log_error(stderr, "failed opening \"%s\"\n", aln_file_nameL);
                exit(1);
            }

            if (aln_streamR == NULL || aln_streamR->is_ok() == false)
            {
                log_error(stderr, "failed opening \"%s\"\n", aln_file_nameR);
                exit(1);
            }

            const uint32 BATCH_SIZE = 500000;
            std::vector<Alignment> batchL( BATCH_SIZE );
            std::vector<Alignment> batchR( BATCH_SIZE );
        }
    }
    catch (nvbio::cuda_error e)
    {
        log_error(stderr, "caught a nvbio::cuda_error exception:\n");
        log_error(stderr, "  %s\n", e.what());
    }
    catch (nvbio::bad_alloc e)
    {
        log_error(stderr, "caught a nvbio::bad_alloc exception:\n");
        log_error(stderr, "  %s\n", e.what());
    }
    catch (nvbio::logic_error e)
    {
        log_error(stderr, "caught a nvbio::logic_error exception:\n");
        log_error(stderr, "  %s\n", e.what());
    }
    catch (nvbio::runtime_error e)
    {
        log_error(stderr, "caught a nvbio::runtime_error exception:\n");
        log_error(stderr, "  %s\n", e.what());
    }
    catch (std::bad_alloc e)
    {
        log_error(stderr, "caught a std::bad_alloc exception:\n");
        log_error(stderr, "  %s\n", e.what());
    }
    catch (std::logic_error &e)
    {
        log_error(stderr, "caught a std::logic_error exception:\n");
        log_error(stderr, "  %s\n", e.what());
    }
    catch (std::runtime_error e)
    {
        log_error(stderr, "caught a std::runtime_error exception:\n");
        log_error(stderr, "  %s\n", e.what());
    }
    catch (...)
    {
        log_error(stderr, "caught an unknown exception!\n");
    }

    return 0;
}
