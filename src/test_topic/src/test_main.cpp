#include <memory>

#include "rclcpp/rclcpp.hpp"
#include "test_subscriber.h"


int main(int argc, char * argv[])
{
  rclcpp::init(argc, argv);
  rclcpp::spin(std::make_shared<TestSubscriber>());
  rclcpp::shutdown();
  return 0;
}