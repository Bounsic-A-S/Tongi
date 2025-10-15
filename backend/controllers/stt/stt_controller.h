#ifndef STT_CONTROLLER_H
#define STT_CONTROLLER_H

#include <pistache/http.h>
#include <pistache/router.h>

class STTController {
public:
    static void getResponseFromMicroService(const Pistache::Rest::Request&, Pistache::Http::ResponseWriter response);
    static void getHealth(const Pistache::Rest::Request&, Pistache::Http::ResponseWriter response);
    static void transcribeAudio(const Pistache::Rest::Request& request, Pistache::Http::ResponseWriter response);
    static void translateAudio(const Pistache::Rest::Request& request, Pistache::Http::ResponseWriter response);
};

#endif
