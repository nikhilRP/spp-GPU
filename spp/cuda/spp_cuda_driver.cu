/*
 * nvbio
 * Copyright (C) 2012-2014, NVIDIA Corporation
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * version 2 as published by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

//#define NVBIO_ENABLE_PROFILING

#define MOD_NAMESPACE
#define MOD_NAMESPACE_BEGIN namespace spp { namespace driver {
#define MOD_NAMESPACE_END   }}
#define MOD_NAMESPACE_NAME spp::driver

#include "spp_cuda_driver.h"
#include "input_thread.h"

namespace nvbio {
namespace spp {
namespace cuda {

int driver(io::SequenceDataStream& read_data_stream1,
		io::SequenceDataStream&	read_data_stream2)
{
    log_visible(stderr, "SPP cuda driver... started\n");

    float polling_time = 0.0f;
    uint32 BATCH_SIZE = 50000;

    // setup the input thread
	InputThread input_thread( &read_data_stream1, &read_data_stream2, BATCH_SIZE );
	input_thread.create();

	uint32 input_set  = 0;
	uint32 n_reads    = 0;

    // loop through the batches of reads
	for (uint32 read_begin = 0; true; read_begin += BATCH_SIZE)
	{
		Timer polling_timer;
		polling_timer.start();

		// poll until the current input set is loaded...
		while (input_thread.read_data1[ input_set ] == NULL ||
			   input_thread.read_data2[ input_set ] == NULL) {}

		polling_timer.stop();
		polling_time += polling_timer.seconds();

		io::SequenceDataHost* read_data_host1 = input_thread.read_data1[ input_set ];
		io::SequenceDataHost* read_data_host2 = input_thread.read_data2[ input_set ];

		if (read_data_host1 == (io::SequenceDataHost*)InputThread::INVALID ||
			read_data_host2 == (io::SequenceDataHost*)InputThread::INVALID)
			break;

		Timer timer;
		timer.start();

		io::SequenceDataDevice read_data1( *read_data_host1/*, io::ReadDataDevice::READS | io::ReadDataDevice::QUALS*/ );
		io::SequenceDataDevice read_data2( *read_data_host2/*, io::ReadDataDevice::READS | io::ReadDataDevice::QUALS*/ );

		timer.stop();

		// mark this set as ready to be reused
		input_thread.read_data1[ input_set ] = NULL;
		input_thread.read_data2[ input_set ] = NULL;

		// advance input set pointer
		input_set = (input_set + 1) % InputThread::BUFFERS;

		const uint32 count = read_data_host1->size();
	}
    log_visible(stderr, "SPP cuda driver... done\n");
    return 0;
}

} // namespace cuda
} // namespace spp
} // namespace nvbio
