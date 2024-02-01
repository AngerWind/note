package com.tiger.controller;

import com.tiger.bean.Admin;
import com.tiger.service.AdminService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.List;

@Controller
@RequestMapping("/admin")
public class AdminController {

    @Autowired
    private AdminService adminService;

    @RequestMapping("/list")
    @ResponseBody
    public List<Admin> getAdminList() {

        System.out.println("dada");
        List<Admin> adminList = adminService.getAdminList();
        System.out.println(adminList);
        return adminList;
    }

}
