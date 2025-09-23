#include "ttt_service.h"
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

std::string TTTService::fetchApiRoot() {
    auto response = cpr::Get(cpr::Url{"http://host.docker.internal:8003/"},
                             cpr::Timeout{5000}); // 5s timeout
    checkForError(response);
    return response.text;
}
std::string TTTService::fetchApiHealth() {
    auto response = cpr::Get(cpr::Url{"http://host.docker.internal:8003/health"},
                             cpr::Timeout{5000}); // 5s timeout
    checkForError(response);
    return response.text;
}

std::string TTTService::fetchApiTranslation(const std::string& body) {
    auto response = cpr::Post(
        cpr::Url{"http://host.docker.internal:8003/process"},
        cpr::Body{body},
        cpr::Header{{"Content-Type", "application/json"}},
        cpr::Timeout{5000}
    );
    checkForError(response);
    return response.text;
}
std::string TTTService::fetchApiTasks() {
    auto response = cpr::Get(cpr::Url{"http://host.docker.internal:8003/tasks"},
                             cpr::Timeout{5000}); // 5s timeout
    checkForError(response);
    return response.text;
}
std::string TTTService::fetchApiLanguages() {
    auto response = cpr::Get(cpr::Url{"http://host.docker.internal:8003/languages"},
                             cpr::Timeout{5000}); // 5s timeout
    checkForError(response);
    return response.text;
}
