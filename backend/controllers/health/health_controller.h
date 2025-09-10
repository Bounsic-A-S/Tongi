#ifndef HEALTH_CONTROLLER_H
#define HEALTH_CONTROLLER_H

#include <pistache/http.h>
#include <pistache/router.h>

class HealthController {
public:
    static void root(const Pistache::Rest::Request&, Pistache::Http::ResponseWriter response);
    static void hello(const Pistache::Rest::Request&, Pistache::Http::ResponseWriter response);
    static void checkHealth(const Pistache::Rest::Request&, Pistache::Http::ResponseWriter response);
};

#endif
