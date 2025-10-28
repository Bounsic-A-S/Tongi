#include "tts_service.h"
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

std::string TTSService::fetchApiRoot() {
    cpr::Response response = cpr::Get(cpr::Url{"https://tts-server-app.bravefield-d0689482.eastus.azurecontainerapps.io/"},
                             cpr::Timeout{5000}); // 5s timeout
    std::string err = checkForError(response);
    if (!err.empty()) return err;
    return response.text;
}
std::string TTSService::fetchApiHealth() {
    cpr::Response response = cpr::Get(cpr::Url{"https://tts-server-app.bravefield-d0689482.eastus.azurecontainerapps.io/health"},
                             cpr::Timeout{5000}); // 5s timeout
    std::string err = checkForError(response);
    if (!err.empty()) return err;
    return response.text;
}


std::string TTSService::fetchApiSynthesize(const std::string& body) {
    cpr::Response response = cpr::Post(
        cpr::Url{"https://tts-server-app.bravefield-d0689482.eastus.azurecontainerapps.io/synthesize"},
        cpr::Body{body},
        cpr::Header{{"Content-Type", "application/json"}},
        cpr::Timeout{10000}
    );

    std::string err = checkForError(response);
    if (!err.empty()) return err;
    return response.text;
}


std::string TTSService::fetchApiVoices() {
    cpr::Response response = cpr::Get(
        cpr::Url{"https://tts-server-app.bravefield-d0689482.eastus.azurecontainerapps.io/voices"},
        cpr::Timeout{5000}
    );

    std::string err = checkForError(response);
    if (!err.empty()) return err;
    return response.text;
}