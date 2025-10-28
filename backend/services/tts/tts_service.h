#ifndef TTS_SERVICE_H
#define TTS_SERVICE_H

#include <string>
#include <pistache/http.h>
#include <pistache/router.h>

class TTSService {
public:
    static std::string fetchApiRoot();
    static std::string fetchApiHealth();
    static std::string fetchApiSynthesize(const std::string& body);
    static std::string fetchApiVoices();
};

#endif
