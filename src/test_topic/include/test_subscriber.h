#ifndef TEST_PUBSUB_H
#define TEST_PUBSUB_H

#include <chrono>
#include <functional>
#include <memory>

#include "rclcpp/rclcpp.hpp"
#include "std_msgs/msg/int32.hpp"

class TestSubscriber: public rclcpp::Node
{
  public:
    TestSubscriber();

  private:
    void topic_callback(const std_msgs::msg::Int32::SharedPtr msg);
    rclcpp::Subscription<std_msgs::msg::Int32>::SharedPtr subscription_;
    rclcpp::Publisher<std_msgs::msg::Int32>::SharedPtr publisher_;
};

#endif