#include "data_service.h"
#include <mutex>
#include <vector>
#include "../models/data/data_model.h"
#include "../utils/json_utils.h"
// file that is mocked up to show how to do a service in this arquitecture
namespace {
    std::mutex mtx;
    std::vector<DataRecord> storage; // Simple almacén en memoria
}

std::string DataService::fetchData() {
    std::lock_guard<std::mutex> lock(mtx);

    // Serializar a JSON simple sin dependencias externas
    std::string arr = "[";
    for (size_t i = 0; i < storage.size(); ++i) {
        arr += "{\"id\":" + std::to_string(storage[i].id) +
               ",\"payload\":\"" + json_escape(storage[i].payload) + "\"}";
        if (i + 1 < storage.size()) arr += ",";
    }
    arr += "]";

    return "{\"data\":" + arr + ",\"count\":" + std::to_string(storage.size()) + "}";
}

std::string DataService::saveData(const std::string& body) {
    std::lock_guard<std::mutex> lock(mtx);
    int nextId = storage.empty() ? 1 : (storage.back().id + 1);
    storage.push_back(DataRecord{ nextId, body });

    return std::string("{\"message\":\"Data saved\",\"id\":") + std::to_string(nextId) +
           ",\"payload\":\"" + json_escape(body) + "\"}";
}
