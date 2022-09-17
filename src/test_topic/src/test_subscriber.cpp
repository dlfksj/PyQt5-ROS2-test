#include "test_subscriber.h"

#include "rclcpp/rclcpp.hpp"

using std::placeholders::_1;

TestSubscriber::TestSubscriber():Node("test_subscriber")
{
    subscription_ = this->create_subscription<std_msgs::msg::Int32>(
                    "topic1", 10, std::bind(&TestSubscriber::topic_callback, this, _1));

    publisher_ = this->create_publisher<std_msgs::msg::Int32>("topic2", 10);
}

void TestSubscriber::topic_callback(const std_msgs::msg::Int32::SharedPtr msg)
{
    auto message = std_msgs::msg::Int32();
    message.data = msg->data + 1;
    publisher_->publish(message);

    RCLCPP_INFO(this->get_logger(), "I heard: '%d'", msg->data);
    RCLCPP_INFO(this->get_logger(), "Publishing: '%d'", message.data);
}