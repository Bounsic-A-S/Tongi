#ifndef TTT_SERVICE_H
#define TTT_SERVICE_H

#include <string>

class TTTService {
public:
    static std::string fetchApiHealth();
    static std::string fetchApiTranslation(const std::string& body);

};

#endif
