#include "ttt_service.h"
#include <cpr/cpr.h>
#include <string>

std::string TTTService::fetchApiData() {
    auto response = cpr::Get(cpr::Url{"http://host.docker.internal:8003"},
                             cpr::Timeout{5000}); // 5s timeout

    if (response.error) {
        return "{\"error\":\"Request failed: " + response.error.message + "\"}";
    }

    if (response.status_code != 200) {
        return "{\"error\":\"HTTP " + std::to_string(response.status_code) + "\"}";
    }

    return response.text;
}
