#ifndef STT_SERVICE_H
#define STT_SERVICE_H

#include <string>

class STTService {
public:
    static std::string fetchApiRoot();
    static std::string fetchApiHealth();

};

#endif
