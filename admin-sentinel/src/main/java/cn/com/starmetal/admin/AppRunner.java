package cn.com.starmetal.admin;

import de.codecentric.boot.admin.server.config.EnableAdminServer;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;

/**
 * @create: 2019-07-04 11:41
 * @author: rikugun<rikugun @ ymail.com>
 * @description: 启动器
 **/
@SpringBootApplication
@EnableDiscoveryClient
@EnableAdminServer
public class AppRunner {

    public static void main(String[] args) {
        SpringApplication.run(AppRunner.class, args);
    }


}
