package com.example.demo1;

import com.example.example4springboot.entity.Widget;
import com.example.example4springboot.service.WidgetService;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.assertj.core.api.Assertions;
import org.assertj.core.util.Lists;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.autoconfigure.web.servlet.WebMvcTest;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.mock.web.MockHttpServletResponse;
import org.springframework.test.web.servlet.MockMvc;

import java.util.Optional;

import static org.mockito.Mockito.doReturn;
import static org.mockito.ArgumentMatchers.any;

import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.*;

import static org.hamcrest.Matchers.*;

// @SpringBootTest // 将Spring与Junit进行集成
// @AutoConfigureMockMvc注释告诉Spring 创建一个与应用程序上下文关联的MockMvc实例，以便它可以将请求传递给处理它们的Controller
// @AutoConfigureMockMvc
// @WebMvcTest结合了@SpringBootTest和@AutoConfigureMockMvc的功能,
// 默认情况下他会扫描所有的bean, 我们指定WidgetRestController.class, 那么他只会创建于WidgetRestController相关的bean, 可以加快测试
@WebMvcTest(WidgetRestController.class)
@AutoConfigureMybatis // mybatis配置mapper
class WidgetRestControllerTest {

    // 创建一个WidgetService mockbean, 用来模拟各种情况的WidgetService
    @MockBean
    private WidgetService service;

    // 自动注入MockMvc, 用来将请求传递给Controller
    @Autowired
    private MockMvc mockMvc;

    @Test
    @DisplayName("GET /widgets success")
    void testGetWidgetsSuccess() throws Exception {
        // 定义WidgetService的行为
        Widget widget1 = new Widget(1L, "Widget Name", "Description", 1);
        Widget widget2 = new Widget(2L, "Widget 2 Name", "Description 2", 4);
        doReturn(Lists.newArrayList(widget1, widget2)).when(service).findAll();

        // 发送请求到Controller中, 并对返回的结果进行断言
        mockMvc.perform(get("/rest/widgets"))
                // 断言返回的http code
                .andExpect(status().isOk())
                // 断言返回的context-type
                .andExpect(content().contentType(MediaType.APPLICATION_JSON))

                // 断言返回的http header
                .andExpect(header().string(HttpHeaders.LOCATION, "/rest/widgets"))

                // 断言返回的responsebody中的json
                .andExpect(jsonPath("$", hasSize(2)))
                .andExpect(jsonPath("$[0].id", is(1)))
                .andExpect(jsonPath("$[0].name", is("Widget Name")))
                .andExpect(jsonPath("$[0].description", is("Description")))
                .andExpect(jsonPath("$[0].version", is(1)))
                .andExpect(jsonPath("$[1].id", is(2)))
                .andExpect(jsonPath("$[1].name", is("Widget 2 Name")))
                .andExpect(jsonPath("$[1].description", is("Description 2")))
                .andExpect(jsonPath("$[1].version", is(4)));
    }
    
    @Test
    void testGetWidgetsSuccess2() throws Exception {
        // 定义WidgetService的行为
        Widget widget1 = new Widget(1L, "Widget Name", "Description", 1);
        Widget widget2 = new Widget(2L, "Widget 2 Name", "Description 2", 4);
        doReturn(Lists.newArrayList(widget1, widget2)).when(service).findAll();

        // 发送请求到Controller中, 并对返回的结果进行断言
        MockHttpServletResponse response = mockMvc.perform(get("/rest/widgets"))
                // 断言返回的http code
                .andExpect(status().isOk())
                // 断言返回的context-type
                .andExpect(content().contentType(MediaType.APPLICATION_JSON))

                // 断言返回的http header
                .andExpect(header().string(HttpHeaders.LOCATION, "/rest/widgets")).andReturn().getResponse();

        // 断言http状态
        Assertions.assertThat(response.getStatus()).isEqualTo(HttpStatus.OK.value());

        // 断言header
        Assertions.assertThat(response.getHeader(HttpHeaders.LOCATION)).isEqualTo("/rest/widgets");
        // 断言content-type
        Assertions.assertThat(response.getContentType()).isEqualTo(MediaType.APPLICATION_JSON.toString());
        // 断言返回的responsebody中的json
        Assertions.assertThat(response.getContentAsString()).isEqualTo(asJsonString(Lists.newArrayList(widget1, widget2)));

    }


    @Test
    @DisplayName("GET /rest/widget/1 - Not Found")
    void testGetWidgetByIdNotFound() throws Exception {
        // Setup our mocked service
        doReturn(Optional.empty()).when(service).findById(1L);

        // Execute the GET request
        mockMvc.perform(get("/rest/widget/{id}", 1L))
                // Validate the response code
                .andExpect(status().isNotFound());
    }

    @Test
    @DisplayName("POST /rest/widget")
    void testCreateWidget() throws Exception {
        // Setup our mocked service
        Widget widgetToPost = new Widget("New Widget", "This is my widget");
        Widget widgetToReturn = new Widget(1L, "New Widget", "This is my widget", 1);
        doReturn(widgetToReturn).when(service).save(any());

        // 执行post请求
        mockMvc.perform(post("/rest/widget")
                        .contentType(MediaType.APPLICATION_JSON)
                        // 指定request body
                        .content(asJsonString(widgetToPost)))

                // Validate the response code and content type
                .andExpect(status().isCreated())
                .andExpect(content().contentType(MediaType.APPLICATION_JSON))

                // Validate headers
                .andExpect(header().string(HttpHeaders.LOCATION, "/rest/widget/1"))
                .andExpect(header().string(HttpHeaders.ETAG, "1"))

                // Validate the returned fields
                .andExpect(jsonPath("$.id", is(1)))
                .andExpect(jsonPath("$.name", is("New Widget")))
                .andExpect(jsonPath("$.description", is("This is my widget")))
                .andExpect(jsonPath("$.version", is(1)));
    }

    static String asJsonString(final Object obj) {
        try {
            return new ObjectMapper().writeValueAsString(obj);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }
}