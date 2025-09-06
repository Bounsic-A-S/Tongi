#include <gtest/gtest.h>
#include "../services/data/data_service.h"

TEST(DataServiceTest, FetchDataReturnsJson) {
    std::string result = DataService::fetchData();
    EXPECT_NE(result.find("\"data\""), std::string::npos);
    // this would expect specific items if we had a real database XD (or implementation of this method)
    // EXPECT_NE(result.find("item1"), std::string::npos);
}

TEST(DataServiceTest, SaveDataReturnsPayload) {
    std::string input = "test_payload";
    std::string result = DataService::saveData(input);
    EXPECT_NE(result.find(input), std::string::npos);
}
