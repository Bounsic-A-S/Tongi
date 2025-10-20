#ifndef STT_SERVICE_H
#define STT_SERVICE_H

#include <string>
#include <pistache/http.h>
#include <pistache/router.h>

class STTService {
public:
    static std::string fetchApiRoot();
    static std::string fetchApiHealth();
    static void transcribeEndpoint(const Pistache::Rest::Request& request, Pistache::Http::ResponseWriter response);
    static void translateEndpoint(const Pistache::Rest::Request& request, Pistache::Http::ResponseWriter response);
    

};

#endif
