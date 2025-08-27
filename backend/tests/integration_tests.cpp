#include <gtest/gtest.h>
#include <cstdlib>
#include <sstream>
#include <string>
#include <thread>
#include <chrono>

// Simple function to execute curl commands and get response
std::pair<int, std::string> executeCurl(const std::string& url, const std::string& method = "GET", const std::string& data = "") {
    std::string command = "curl -s -w \"HTTPSTATUS:%{http_code}\" ";
    
    if (method == "POST") {
        command += "-X POST ";
        if (!data.empty()) {
            command += "-H \"Content-Type: application/json\" ";
            command += "-d \"" + data + "\" ";
        }
    }
    
    command += url;
    
    FILE* pipe = popen(command.c_str(), "r");
    if (!pipe) return {-1, ""};
    
    std::string result;
    char buffer[256];
    while (fgets(buffer, sizeof(buffer), pipe) != nullptr) {
        result += buffer;
    }
    
    int exitCode = pclose(pipe);
    
    // Extract HTTP status code
    size_t statusPos = result.find("HTTPSTATUS:");
    int httpCode = 0;
    std::string body = result;
    
    if (statusPos != std::string::npos) {
        std::string statusStr = result.substr(statusPos + 11);
        httpCode = std::stoi(statusStr);
        body = result.substr(0, statusPos);
    }
    
    return {httpCode, body};
}

class IntegrationTest : public ::testing::Test {
protected:
    void SetUp() override {
        baseUrl = "http://localhost:9080";
        // Wait a bit to ensure server is running
        std::this_thread::sleep_for(std::chrono::seconds(1));
    }
    
    std::string baseUrl;
};

TEST_F(IntegrationTest, ServerIsRunning) {
    auto [httpCode, body] = executeCurl(baseUrl + "/api/health");
    
    ASSERT_EQ(httpCode, 200);
    ASSERT_TRUE(body.find("healthy") != std::string::npos);
    ASSERT_TRUE(body.find("Tongi Backend") != std::string::npos);
}

TEST_F(IntegrationTest, RootEndpointReturnsHTML) {
    auto [httpCode, body] = executeCurl(baseUrl + "/");
    
    ASSERT_EQ(httpCode, 200);
    ASSERT_TRUE(body.find("<html>") != std::string::npos);
    ASSERT_TRUE(body.find("Tongi Backend Server") != std::string::npos);
}

TEST_F(IntegrationTest, HelloEndpointReturnsJSON) {
    auto [httpCode, body] = executeCurl(baseUrl + "/hello");
    
    ASSERT_EQ(httpCode, 200);
    ASSERT_TRUE(body.find("Hello from Tongi Backend!") != std::string::npos);
    ASSERT_TRUE(body.find("{") != std::string::npos); // Basic JSON check
}

TEST_F(IntegrationTest, GetDataEndpoint) {
    auto [httpCode, body] = executeCurl(baseUrl + "/api/data");
    
    ASSERT_EQ(httpCode, 200);
    ASSERT_TRUE(body.find("item1") != std::string::npos);
    ASSERT_TRUE(body.find("item2") != std::string::npos);
    ASSERT_TRUE(body.find("item3") != std::string::npos);
    ASSERT_TRUE(body.find("count") != std::string::npos);
}

TEST_F(IntegrationTest, PostDataEndpoint) {
    std::string testData = R"({"test": "integration", "value": 123})";
    auto [httpCode, body] = executeCurl(baseUrl + "/api/data", "POST", testData);
    
    ASSERT_EQ(httpCode, 200);
    ASSERT_TRUE(body.find("Data received successfully") != std::string::npos);
    ASSERT_TRUE(body.find("received_data") != std::string::npos);
}

TEST_F(IntegrationTest, InvalidEndpointReturns404) {
    auto [httpCode, body] = executeCurl(baseUrl + "/nonexistent");
    
    ASSERT_EQ(httpCode, 404);
}

int main(int argc, char **argv) {
    ::testing::InitGoogleTest(&argc, argv);
    
    std::cout << "=== Integration Tests ===" << std::endl;
    std::cout << "Note: Make sure the Tongi server is running on port 9080" << std::endl;
    std::cout << "Run: ./tongi_server (or make run) in another terminal" << std::endl;
    std::cout << "=========================" << std::endl;
    
    return RUN_ALL_TESTS();
}
