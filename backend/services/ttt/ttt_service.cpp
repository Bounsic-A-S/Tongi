#include "ttt_service.h"
#include <cpr/cpr.h>
#include <string>

static std::string checkForError(const cpr::Response& response){
    if (response.error) {
        return "{\"error\":\"Request failed: " + response.error.message + "\"}";
    }

    if (response.status_code != 200) {
        return "{\"error\":\"HTTP " + std::to_string(response.status_code) + "\"}";
    }
    
    return "";
}

std::string TTTService::fetchApiRoot() {
    cpr::Response response = cpr::Get(cpr::Url{"https://ttt-server-app.bravefield-d0689482.eastus.azurecontainerapps.io/"},
                             cpr::Timeout{5000}); // 5s timeout
    std::string err = checkForError(response);
    if (!err.empty()) return err;
    return response.text;
}
std::string TTTService::fetchApiHealth() {
    cpr::Response response = cpr::Get(cpr::Url{"https://ttt-server-app.bravefield-d0689482.eastus.azurecontainerapps.io/health"},
                             cpr::Timeout{5000}); // 5s timeout
    std::string err = checkForError(response);
    if (!err.empty()) return err;
    return response.text;
}

std::string TTTService::fetchApiTranslation(const std::string& body) {
    cpr::Response response = cpr::Post(
        cpr::Url{"https://ttt-server-app.bravefield-d0689482.eastus.azurecontainerapps.io/process"},
        cpr::Body{body},
        cpr::Header{{"Content-Type", "application/json"}},
        cpr::Timeout{5000}
    );
    std::string err = checkForError(response);
    if (!err.empty()) return err;
    return response.text;
}
std::string TTTService::fetchApiTasks() {
    cpr::Response response = cpr::Get(cpr::Url{"https://ttt-server-app.bravefield-d0689482.eastus.azurecontainerapps.io/tasks"},
                             cpr::Timeout{5000}); // 5s timeout
    std::string err = checkForError(response);
    if (!err.empty()) return err;
    return response.text;
}
std::string TTTService::fetchApiLanguages() {
    cpr::Response response = cpr::Get(cpr::Url{"https://ttt-server-app.bravefield-d0689482.eastus.azurecontainerapps.io/languages"},
                             cpr::Timeout{5000}); // 5s timeout
    std::string err = checkForError(response);
    if (!err.empty()) return err;
    return response.text;
}
