#ifndef DATA_CONTROLLER_H
#define DATA_CONTROLLER_H

#include <pistache/http.h>
#include <pistache/router.h>

class DataController {
public:
    static void getData(const Pistache::Rest::Request&, Pistache::Http::ResponseWriter response);
    static void postData(const Pistache::Rest::Request& request, Pistache::Http::ResponseWriter response);
};

#endif
