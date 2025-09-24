#include "stt_service.h"
#include <cpr/cpr.h>
#include <string>

std::string checkForError(auto response){
    if (response.error) {
        return "{\"error\":\"Request failed: " + response.error.message + "\"}";
    }

    if (response.status_code != 200) {
        return "{\"error\":\"HTTP " + std::to_string(response.status_code) + "\"}";
    }
    
    return "";
}

std::string STTService::fetchApiRoot() {
    auto response = cpr::Get(cpr::Url{"http://host.docker.internal:8001/"},
                             cpr::Timeout{5000}); // 5s timeout
    checkForError(response);
    return response.text;
}
std::string STTService::fetchApiHealth() {
    auto response = cpr::Get(cpr::Url{"http://host.docker.internal:8001/health"},
                             cpr::Timeout{5000}); // 5s timeout
    checkForError(response);
    return response.text;
}