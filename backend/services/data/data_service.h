#ifndef DATA_SERVICE_H
#define DATA_SERVICE_H

#include <string>

class DataService {
public:
    static std::string fetchData();
    static std::string saveData(const std::string& body);
};

#endif
