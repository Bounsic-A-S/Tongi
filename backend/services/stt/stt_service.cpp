#include "stt_service.h"
#include <cpr/cpr.h>
#include <string>
#include <fstream>
#include <cstdio>
#include <iostream>
#include <iomanip>
#include <sstream>

using namespace Pistache;

static std::string checkForError(const cpr::Response& response) {
    if (response.error) {
        return "{\"error\":\"Request failed: " + response.error.message + "\"}";
    }

    if (response.status_code != 200) {
        return "{\"error\":\"HTTP " + std::to_string(response.status_code) + "\"}";
    }

    return "";
}

// Función auxiliar para verificar si es un archivo WAV válido
static bool isValidWavFile(const std::string& filepath) {
    std::ifstream file(filepath, std::ios::binary);
    if (!file.is_open()) return false;
    
    char header[12];
    file.read(header, 12);
    
    // Verificar magic numbers: "RIFF" y "WAVE"
    bool isRiff = (header[0] == 'R' && header[1] == 'I' && header[2] == 'F' && header[3] == 'F');
    bool isWave = (header[8] == 'W' && header[9] == 'A' && header[10] == 'V' && header[11] == 'E');
    
    return isRiff && isWave;
}

// Función para extraer el boundary del Content-Type
static std::string extractBoundary(const std::string& contentType) {
    size_t pos = contentType.find("boundary=");
    if (pos == std::string::npos) return "";
    
    std::string boundary = contentType.substr(pos + 9);
    // Remover comillas si existen
    if (!boundary.empty() && boundary[0] == '"') {
        boundary = boundary.substr(1, boundary.length() - 2);
    }
    return boundary;
}

// Función para parsear multipart y extraer el archivo
static bool extractFileFromMultipart(const std::string& body, const std::string& boundary, 
                                     std::string& fileData, std::string& filename) {
    std::string delimiter = "--" + boundary;
    size_t pos = 0;
    
    while (pos < body.length()) {
        size_t partStart = body.find(delimiter, pos);
        if (partStart == std::string::npos) break;
        
        partStart += delimiter.length();
        size_t partEnd = body.find(delimiter, partStart);
        if (partEnd == std::string::npos) partEnd = body.length();
        
        // Extraer la parte
        std::string part = body.substr(partStart, partEnd - partStart);
        
        // Buscar el final de los headers (doble salto de línea)
        size_t headerEnd = part.find("\r\n\r\n");
        if (headerEnd == std::string::npos) {
            pos = partEnd;
            continue;
        }
        
        std::string headers = part.substr(0, headerEnd);
        
        // Verificar si es el campo "file"
        if (headers.find("name=\"file\"") != std::string::npos) {
            // Extraer el nombre del archivo
            size_t filenamePos = headers.find("filename=\"");
            if (filenamePos != std::string::npos) {
                filenamePos += 10; // longitud de "filename=\""
                size_t filenameEnd = headers.find("\"", filenamePos);
                if (filenameEnd != std::string::npos) {
                    filename = headers.substr(filenamePos, filenameEnd - filenamePos);
                }
            }
            
            // Extraer el contenido del archivo
            fileData = part.substr(headerEnd + 4); // +4 para saltar \r\n\r\n
            
            // Remover el \r\n final si existe
            if (fileData.length() >= 2 && fileData.substr(fileData.length() - 2) == "\r\n") {
                fileData = fileData.substr(0, fileData.length() - 2);
            }
            
            return true;
        }
        
        pos = partEnd;
    }
    
    return false;
}

static std::string extractTextFieldFromMultipart(const std::string& body, const std::string& boundary, const std::string& fieldName) {
    std::string delimiter = "--" + boundary;
    std::string fieldNameToFind = "name=\"" + fieldName + "\"";
    size_t pos = 0;

    while (pos < body.length()) {
        size_t partStart = body.find(delimiter, pos);
        if (partStart == std::string::npos) break;

        partStart += delimiter.length();
        if (body.substr(partStart, 2) == "--") break; // Fin del multipart
        partStart += 2; // Saltar \r\n

        size_t partEnd = body.find(delimiter, partStart);
        if (partEnd == std::string::npos) partEnd = body.length();
        
        std::string part = body.substr(partStart, partEnd - partStart);
        
        size_t headerEnd = part.find("\r\n\r\n");
        if (headerEnd == std::string::npos) {
            pos = partEnd;
            continue;
        }

        std::string headers = part.substr(0, headerEnd);
        
        // Verificar si es el campo que buscamos Y NO es un archivo
        if (headers.find(fieldNameToFind) != std::string::npos && headers.find("filename=\"") == std::string::npos) {
            std::string data = part.substr(headerEnd + 4); // +4 para \r\n\r\n
            
            // Remover \r\n final si existe
            if (data.length() >= 2 && data.substr(data.length() - 2) == "\r\n") {
                data = data.substr(0, data.length() - 2);
            }
            return data;
        }
        
        pos = partEnd;
    }

    return ""; // Devuelve vacío si no lo encuentra
}

std::string STTService::fetchApiRoot() {
    cpr::Response response = cpr::Get(cpr::Url{"https://stt-server-app.bravefield-d0689482.eastus.azurecontainerapps.io/"},
                             cpr::Timeout{5000});
    std::string err = checkForError(response);
    if (!err.empty()) return err;
    return response.text;
}

std::string STTService::fetchApiHealth() {
    cpr::Response response = cpr::Get(cpr::Url{"https://stt-server-app.bravefield-d0689482.eastus.azurecontainerapps.io/health"},
                             cpr::Timeout{5000});
    std::string err = checkForError(response);
    if (!err.empty()) return err;
    return response.text;
}

// ---------------------------------------------------------------------------
// ENDPOINT: /transcribe
// ---------------------------------------------------------------------------
void STTService::transcribeEndpoint(const Rest::Request& request, Http::ResponseWriter response) {
    try {
        std::cout << "=== TRANSCRIBE REQUEST ===" << std::endl;
        std::cout << "Body size: " << request.body().size() << " bytes" << std::endl;

        // Obtener Content-Type para detectar boundary
        auto contentTypeHeader = request.headers().tryGet("Content-Type");
        if (!contentTypeHeader) {
            response.send(Http::Code::Bad_Request, "{\"error\":\"Missing Content-Type header\"}");
            return;
        }
        
        std::stringstream ss;
        contentTypeHeader->write(ss);
        std::string contentType = ss.str();
        std::cout << "Content-Type header: " << contentType << std::endl;
        
        // Extraer boundary
        std::string boundary = extractBoundary(contentType);
        if (boundary.empty()) {
            response.send(Http::Code::Bad_Request, "{\"error\":\"Missing boundary in Content-Type\"}");
            return;
        }
        
        std::cout << "Boundary: " << boundary << std::endl;
        
        // Extraer el archivo del multipart
        std::string fileData, filename;
        if (!extractFileFromMultipart(request.body(), boundary, fileData, filename)) {
            response.send(Http::Code::Bad_Request, "{\"error\":\"No se encontró el archivo en el multipart\"}");
            return;
        }
        
        std::cout << "Archivo extraído: " << filename << " (" << fileData.size() << " bytes)" << std::endl;

        // Obtener idioma desde query o usar por defecto
        auto language = request.query().get("language").value_or("es-ES");

        // Guardar temporalmente el archivo extraído
        const std::string tempFile = "/tmp/temp_audio.wav";
        {
            std::ofstream out(tempFile, std::ios::binary);
            out.write(fileData.c_str(), fileData.size());
        }

        // Verificar tamaño
        std::ifstream check(tempFile, std::ios::binary | std::ios::ate);
        if (!check.is_open()) {
            response.send(Http::Code::Internal_Server_Error, "{\"error\":\"No se pudo crear archivo temporal\"}");
            return;
        }
        
        auto size = check.tellg();
        check.close();

        std::cout << "Archivo guardado: " << tempFile << " (" << size << " bytes)" << std::endl;

        if (size == 0) {
            response.send(Http::Code::Bad_Request, "{\"error\":\"Archivo vacío\"}");
            return;
        }

        // Verificar si es un WAV válido
        bool isWav = isValidWavFile(tempFile);
        std::cout << "Es archivo WAV válido: " << (isWav ? "SÍ" : "NO") << std::endl;
        
        if (!isWav) {
            std::ifstream hexCheck(tempFile, std::ios::binary);
            char bytes[16];
            hexCheck.read(bytes, 16);
            std::cout << "Primeros bytes (hex): ";
            for (int i = 0; i < 16 && i < hexCheck.gcount(); i++) {
                std::cout << std::hex << std::setw(2) << std::setfill('0') 
                          << (int)(unsigned char)bytes[i] << " ";
            }
            std::cout << std::dec << std::endl;
        }

        // Crear multipart para enviar al microservicio
        cpr::Multipart multipart({
            {"file", cpr::File{tempFile}},
            {"language", language}
        });

        std::cout << "Enviando a microservicio..." << std::endl;
        cpr::Response apiResponse = cpr::Post(
            cpr::Url{"https://stt-server-app.bravefield-d0689482.eastus.azurecontainerapps.io/transcribe"},
            multipart,
            cpr::Timeout{30000}
        );

        std::remove(tempFile.c_str());

        std::string err = checkForError(apiResponse);
        if (!err.empty()) {
            std::cout << "ERROR en respuesta: " << err << std::endl;
            response.send(Http::Code::Internal_Server_Error, err);
            return;
        }

        std::cout << "Transcripción exitosa" << std::endl;
        response.send(Http::Code::Ok, apiResponse.text, MIME(Application, Json));

    } catch (const std::exception& e) {
        std::cout << "EXCEPTION: " << e.what() << std::endl;
        response.send(Http::Code::Internal_Server_Error,
                      "{\"error\":\"Exception: " + std::string(e.what()) + "\"}");
    }
}

// ---------------------------------------------------------------------------
// ENDPOINT: /transcribe/translate
// ---------------------------------------------------------------------------
void STTService::translateEndpoint(const Rest::Request& request, Http::ResponseWriter response) {
    try {
        std::cout << "=== TRANSLATE REQUEST ===" << std::endl;
        std::cout << "Body size: " << request.body().size() << " bytes" << std::endl;

        // Obtener Content-Type para detectar boundary
        auto contentTypeHeader = request.headers().tryGet("Content-Type");
        if (!contentTypeHeader) {
            response.send(Http::Code::Bad_Request, "{\"error\":\"Missing Content-Type header\"}");
            return;
        }
        
        std::stringstream ss;
        contentTypeHeader->write(ss);
        std::string contentType = ss.str();
        std::cout << "Content-Type header: " << contentType << std::endl;
        
        // Extraer boundary
        std::string boundary = extractBoundary(contentType);
        if (boundary.empty()) {
            response.send(Http::Code::Bad_Request, "{\"error\":\"Missing boundary in Content-Type\"}");
            return;
        }
        
        std::cout << "Boundary: " << boundary << std::endl;
        
        // Extraer el archivo del multipart
        std::string fileData, filename;
        if (!extractFileFromMultipart(request.body(), boundary, fileData, filename)) {
            response.send(Http::Code::Bad_Request, "{\"error\":\"No se encontró el archivo en el multipart\"}");
            return;
        }
        
        std::cout << "Archivo extraído: " << filename << " (" << fileData.size() << " bytes)" << std::endl;

        std::string sourceLang = extractTextFieldFromMultipart(request.body(), boundary, "source_language");
        std::string targetLang = extractTextFieldFromMultipart(request.body(), boundary, "target_language");
        
        if (sourceLang.empty()) sourceLang = "es-ES";
        if (targetLang.empty()) targetLang = "en-US";

        // Guardar archivo temporal
        const std::string tempFile = "/tmp/temp_translate.wav";
        {
            std::ofstream out(tempFile, std::ios::binary);
            out.write(fileData.c_str(), fileData.size());
        }

        // Validar tamaño
        std::ifstream check(tempFile, std::ios::binary | std::ios::ate);
        if (!check.is_open()) {
            response.send(Http::Code::Internal_Server_Error, "{\"error\":\"No se pudo crear archivo temporal\"}");
            return;
        }

        auto size = check.tellg();
        check.close();
        
        std::cout << "Archivo temporal guardado: " << size << " bytes en " << tempFile << std::endl;

        if (size <= 0) {
            response.send(Http::Code::Bad_Request, "{\"error\":\"Archivo de audio vacío\"}");
            return;
        }

        // Verificar si es un WAV válido
        bool isWav = isValidWavFile(tempFile);
        std::cout << "Es archivo WAV válido: " << (isWav ? "SÍ" : "NO") << std::endl;
        
        if (!isWav) {
            std::ifstream hexCheck(tempFile, std::ios::binary);
            char bytes[16];
            hexCheck.read(bytes, 16);
            std::cout << "Primeros bytes (hex): ";
            for (int i = 0; i < 16 && i < hexCheck.gcount(); i++) {
                std::cout << std::hex << std::setw(2) << std::setfill('0') 
                          << (int)(unsigned char)bytes[i] << " ";
            }
            std::cout << std::dec << std::endl;
        }

        // Armar multipart con campos y archivo
        cpr::Multipart multipart({
            {"file", cpr::File{tempFile}},
            {"source_language", sourceLang},
            {"target_language", targetLang}
        });

        std::cout << "Enviando a microservicio..." << std::endl;
        cpr::Response apiResponse = cpr::Post(
            cpr::Url{"https://stt-server-app.bravefield-d0689482.eastus.azurecontainerapps.io/transcribe/translate"},
            multipart,
            cpr::Timeout{30000}
        );

        std::remove(tempFile.c_str());

        std::string err = checkForError(apiResponse);
        if (!err.empty()) {
            std::cout << "ERROR en respuesta: " << err << std::endl;
            response.send(Http::Code::Internal_Server_Error, err);
            return;
        }

        std::cout << "Traducción exitosa" << std::endl;
        response.send(Http::Code::Ok, apiResponse.text, MIME(Application, Json));

    } catch (const std::exception& e) {
        std::cout << "EXCEPTION: " << e.what() << std::endl;
        response.send(Http::Code::Internal_Server_Error,
                      "{\"error\":\"Exception: " + std::string(e.what()) + "\"}");
    }


}