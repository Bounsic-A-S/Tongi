#ifndef TTT_CONTROLLER_H
#define TTT_CONTROLLER_H

#include <pistache/http.h>
#include <pistache/router.h>

class TTTController {
public:
    static void getTextTranslation(const Pistache::Rest::Request&, Pistache::Http::ResponseWriter response);
};

#endif
