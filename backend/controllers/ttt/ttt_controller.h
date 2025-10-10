#ifndef TTT_CONTROLLER_H
#define TTT_CONTROLLER_H

#include <pistache/http.h>
#include <pistache/router.h>

class TTTController {
public:
    static void getResponseFromMicroService(const Pistache::Rest::Request&, Pistache::Http::ResponseWriter response);
    static void getHealth(const Pistache::Rest::Request&, Pistache::Http::ResponseWriter response);
    static void TextTranslation(const Pistache::Rest::Request&, Pistache::Http::ResponseWriter response);
    static void getTasks(const Pistache::Rest::Request&, Pistache::Http::ResponseWriter response);
    static void getLanguagesAvailable(const Pistache::Rest::Request&, Pistache::Http::ResponseWriter response);

};

#endif
