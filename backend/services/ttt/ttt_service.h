#ifndef TTT_SERVICE_H
#define TTT_SERVICE_H

#include <string>
#include <pistache/http.h>
#include <pistache/router.h>

class TTTService {
public:
    static std::string fetchApiRoot();
    static std::string fetchApiHealth();
    static std::string fetchApiTranslation(const std::string& body);
    static std::string fetchApiTasks();
    static std::string fetchApiLanguages();

};

#endif
