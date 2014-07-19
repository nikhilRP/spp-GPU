#pragma once

#include <nvbio/basic/threads.h>
#include <nvbio/basic/timer.h>
#include <nvbio/io/sequence/sequence.h>

namespace nvbio {
namespace spp {
namespace cuda {

struct InputThread : public Thread<InputThread>
{
    static const uint32 BUFFERS = 4;
    static const uint32 INVALID = 1u;

    InputThread(io::SequenceDataStream* read_data_stream1, io::SequenceDataStream* read_data_stream2, const uint32 batch_size) :
        m_read_data_stream1( read_data_stream1 ), m_read_data_stream2( read_data_stream2 ), m_batch_size( batch_size ), m_set(0)
    {
        for (uint32 i = 0; i < BUFFERS; ++i)
            read_data1[i] = read_data2[i] = NULL;
    }

    void run();

    io::SequenceDataStream* m_read_data_stream1;
    io::SequenceDataStream* m_read_data_stream2;
    uint32                  m_batch_size;
    volatile uint32         m_set;

    io::SequenceDataHost read_data_storage1[BUFFERS];
    io::SequenceDataHost read_data_storage2[BUFFERS];

    io::SequenceDataHost* volatile read_data1[BUFFERS];
    io::SequenceDataHost* volatile read_data2[BUFFERS];
};

} // namespace cuda
} // namespace spp
} // namespace nvbio
