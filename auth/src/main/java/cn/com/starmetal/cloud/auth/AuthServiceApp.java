package cn.com.starmetal.cloud.auth;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;

/**
 * @create: 2019-07-05 15:27
 * @author: rikugun<rikugun @ ymail.com>
 * @description: 鉴权认证服务
 **/
@SpringBootApplication
@EnableDiscoveryClient
public class AuthServiceApp {
    public static void main(String[] args) {
        SpringApplication.run(AuthServiceApp.class,args);
    }

}
