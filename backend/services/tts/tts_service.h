#ifndef TTS_SERVICE_H
#define TTS_SERVICE_H

#include <string>

class TTSService {
public:
    static std::string fetchApiRoot();
    static std::string fetchApiHealth();

};

#endif
