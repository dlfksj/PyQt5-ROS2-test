import sys
import rclpy
from rclpy.node import Node
# from rclpy.executors import MultiThreadedExecutor
from std_msgs.msg import Int32
from PyQt5 import QtWidgets
from PyQt5.QtWidgets import *
from PyQt5.QtGui import *
from PyQt5.QtCore import *
from threading import Thread


forceQuit = False

class Ros2Node(Node):
    def __init__(self, node_name):
        super().__init__(node_name)
        self.num = 0
        self.publisher_ = self.create_publisher(Int32, 'topic1', 10)
        self.subscription_ = self.create_subscription(Int32, 'topic2', self.listener_callback, 10)

    def publish_message(self, num):
        msg = Int32()
        msg.data = num
        self.get_logger().info('Publishing: "%d"' % msg.data)
        self.publisher_.publish(msg)

    def listener_callback(self, msg):
        self.get_logger().info('I heard: "%d"' % msg.data)
        self.num = msg.data


class MyApp(QWidget):
    def __init__(self, ros2_node):
        super().__init__()
        self.ros2_node = ros2_node

        # spin ros2 node
        self.ros2_thread = Thread(target=rclpy.spin, args=(self.ros2_node, ))
        self.ros2_thread.start()

        # variable
        self.num = 0

        # UI
        self.initUI()

        # timer
        self.timer = QTimer(self)
        self.timer.start(100)     # [ms]
        self.timer.timeout.connect(self.display)

    def initUI(self):
        self.setWindowTitle("GCS")
        self.window_width, self.window_height = 514, 360
        self.setMinimumSize(self.window_width, self.window_height)

        self.disp = QTextBrowser(self)
        self.disp.move(10,50)
        self.disp.setPlainText(str(self.num))

        self.btn = QPushButton("Plus Button", self)
        self.btn.clicked.connect(self.button_callback)
    
    def button_callback(self):
        self.ros2_node.publish_message(self.num)

    def display(self):
        self.num = self.ros2_node.num
        self.disp.setPlainText(str(self.num))

    def closeEvent(self, event):
        print('Close window')
        rclpy.shutdown()
        self.ros2_thread.join()
        forceQuit = True


def main(args=None):

    # PyQt5를 이용한 모든 프로그램은 반드시 QApplication 객체를 생성
    app = QtWidgets.QApplication(sys.argv)
    
    rclpy.init(args=args)

    node = Ros2Node('pyqt_ros2_tester')

    myapp = MyApp(node)
    myapp.show()       # 윈도우 객체가 화면에 보여지도록 show 메소드 호출

    try:
        app.exec_()    # 이벤트 루프 시작
    except forceQuit:
        app.quit()



if __name__ == '__main__':
    main()