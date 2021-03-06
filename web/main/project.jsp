<%--
  Created by IntelliJ IDEA.
  User: jianwei.zhou
  Date: 2019/10/10
  Time: 10:05
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<html lang="zh">
<head>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <!-- 上述3个meta标签*必须*放在最前面，任何其他内容都*必须*跟随其后！ -->
    <title>项目管理</title>
    <!-- Bootstrap -->
    <link href="../css/bootstrap.min.css" rel="stylesheet">
    <!-- jQuery (Bootstrap 的所有 JavaScript 插件都依赖 jQuery，所以必须放在前边) -->
    <script src="../js/jquery-1.11.0.min.js"></script>
    <!-- 加载 Bootstrap 的所有 JavaScript 插件。你也可以根据需要只加载单个插件。 -->
    <script src="../js/bootstrap.min.js"></script>
    <script src="../js/layer.js"></script>
    <link rel="stylesheet" href="../css/initial_default_props.css">
    <link rel="stylesheet" href="../css/table.css">
    <style type="text/css">
        .content_stub_box {
            position: absolute;
            top: 50px;
            left: 200px;
            right: 0px;
            bottom: 0px;
            background-color: #fff;
            padding-left: 30px;
            padding-top: 30px;
            overflow: auto;
        }

        .table_top_func {
            border: #dddddd 1px solid;
            padding: 10px;
        }

        .table_name {
            font-size: 12px;
            height: 35px;
            line-height: 35px;
            padding-left: 30px;
            background-color: #eeeeee;
            border: #dddddd 1px solid;
            margin-top: 30px;
        }

        /*内容区底部分页栏目*/
        .nav_box {
            text-align: center;
            margin-top: 30px;
        }

        .content_stub_box nav {
            margin: 0 auto;
        }

        /*内容区标题*/
        .content_title_box h2 {
            float: left;
        }

        .content_title_box ul {
            float: left;
            margin-left: 50px;
        }

        /*创建项目dialog*/
        #create_projct_stub {
            width: 530px;
            height: 340px;
        }

        .create_form {
            margin-left: 30px;
            margin-top: 30px;
            margin-bottom: 30px;
        }

        .create_layer_cancel {
            float: right;
            margin-right: 30px;
        }

        .create_layer_confirm {
            float: right;
            margin-right: 20px;
        }

        .form_group {
            margin-top: 10px;
        }

        .form_input {
            width: 300px;
            height: 34px;
            padding: 6px 12px;
            font-size: 14px;
            line-height: 1.42857143;
            color: #555;
            background-color: #fff;
            background-image: none;
            border: 1px solid #ccc;
            border-radius: 4px;
        }

        .form_group label {
            display: inline-block;
            width: 90px;
            text-align: right;
        }

    </style>

    <script type="text/javascript">
        // 弹窗的html内容
        var layerHtml = "";
        // 创建主项目弹窗层级
        var createlayerIndex = -1;
        // 获取项目路径
        var $ctx = '<%=request.getContextPath()%>';
        // 弹出层DOM上下文
        var createProjectLayer = undefined;

        $(function () {
            //左边菜单选中
            $("#menu_project").toggleClass("active");
            // 创建项目按钮的点击事件
            $("#create_project").click(function () {
                openCreateLayer();
            });
        });

        function getLayerHtml() {
            if (layerHtml == "") {
                var layerDiv = $("#create_projct_stub");
                layerDiv.css("display", "block");
                layerHtml = layerDiv.html();
                layerDiv.css("display", "none");
            }
            return layerHtml;
        }

        function openCreateLayer() {
            closeCreateLayer();
            var dialogConf = {
                type: 1,
                title: '创建主项目',
                skin: 'layui-layer-rim', //加上边框
                area: ['530px', '340px'], //宽高
                content: getLayerHtml(),
                success: function onCreateProjectLayerShowed(layer, index) {
                    createProjectLayer = layer;
                    createProjectLayer.find("#create_projct_confirm").click(onCreateProjectConfirm);
                    createProjectLayer.find("#create_projct_cancel").click(closeCreateLayer);
                }
            }
            createlayerIndex = layer.open(dialogConf);
        }

        function closeCreateLayer() {
            if (createlayerIndex > 0) {
                layer.close(createlayerIndex);
                createlayerIndex = -1;
            }
        }

        function onCreateProjectConfirm() {
            var number = createProjectLayer.find("#number").val();
            var name = createProjectLayer.find("#name").val();
            var ownerName = createProjectLayer.find("#ownerName").val();
            var note = createProjectLayer.find("#note").val();
            //编号6-10位字母或者数字
            if (!(/^[\w]{6,10}$/.test(number))) {
                createProjectLayer.find("#create_tips").html("编号只能包含字母数字且长度为6-8!");
                return;
            }
            if (name.length == 0) {
                createProjectLayer.find("#create_tips").html("名称不能为空！");
                return;
            }
            if (ownerName.length == 0) {
                createProjectLayer.find("#create_tips").html("业主单位不能为空！");
                return;
            }
            var parameters = {
                "op_type": 1,
                "number": number,
                "name": name,
                "ownerName": ownerName,
                "note": note
            };
            $.post($ctx + "/main/projectServlet.do", parameters, function (response, status) {
                //如果服务器指定响应格式是json，实际数据格式错误，则内部转换错误，结果回调不会执行
                if (status != "success" || response == undefined) {
                    layer.msg('创建失败！ 请检查网络');
                } else if (200 == response.meta.code) {
                    window.location.reload();
                } else {
                    layer.msg(response.meta.msg);
                    createProjectLayer.find("#create_tips").html(response.meta.msg);
                }
            });
        }

        //删除主项目
        function onProjectDeleteClicked(projectNumber) {
            layer.confirm('真的要删除吗？', {
                btn: ['确定', '取消'] //按钮
            }, function () {
                var parameters = {
                    "op_type": "3",
                    "number": projectNumber
                };
                $.post($ctx + "/main/projectServlet.do", parameters, function (response, status) {
                    //如果服务器指定响应格式是json，实际数据格式错误，则内部转换错误，结果回调不会执行
                    if (status != "success" || response == undefined) {
                        layer.msg('删除失败！ 请检查网络');
                    } else if (200 == response.meta.code) {
                        window.location.reload();
                    } else {
                        layer.msg(response.meta.msg);
                    }
                });
            }, function (index) {
                layer.close(index);
            });
        }

        //创建子项目弹窗
        // 弹窗的html内容
        var createSubprojectlayerHtml = "";
        // 弹出层DOM上下文
        var createSubprojectLayer = undefined;

        function onCreateSubprojectClicked(mainProjectNumber) {
            var dialogConf = {
                type: 1,
                title: '创建子项目',
                skin: 'layui-layer-rim', //加上边框
                area: ['510px', '330px'], //宽高
                content: getSubprojectLayerHtml(),
                success: function (layerObject, index) {
                    createSubprojectLayer = layerObject;
                    createSubprojectLayer.find("#subproject_main_project").val(mainProjectNumber);
                    createSubprojectLayer.find("#create_subproject_confirm").click(function () {
                        var number = createSubprojectLayer.find("#subproject_number").val();
                        var name = createSubprojectLayer.find("#subproject_name").val();
                        var mainProject = createSubprojectLayer.find("#subproject_main_project").val();
                        var note = createSubprojectLayer.find("#subproject_note").val();
                        //编号6-10位字母或者数字
                        if (!(/^[\w]{6,10}$/.test(number))) {
                            createSubprojectLayer.find("#create_subproject_tips").html("编号只能包含字母数字且长度为6-8!");
                            return;
                        }
                        if (name.length == 0) {
                            createSubprojectLayer.find("#create_subproject_tips").html("名称不能为空！");
                            return;
                        }
                        if (mainProject.length == 0) {
                            createSubprojectLayer.find("#create_subproject_tips").html("主项目不能为空！");
                            return;
                        }
                        var parameters = {
                            "op_type": "1",
                            "number": number,
                            "name": name,
                            "mainProject": mainProject,
                            "note": note
                        };
                        $.post($ctx + "/main/updateSubProjectServlet.do", parameters, function (response, status) {
                            //如果服务器指定响应格式是json，实际数据格式错误，则内部转换错误，结果回调不会执行
                            if (status != "success" || response == undefined) {
                                layer.msg('创建失败！ 请检查网络');
                            } else if (200 == response.meta.code) {
                                layer.msg('创建成功！');
                                layer.close(index);
                            } else {
                                layer.msg(response.meta.msg);
                                createSubprojectLayer.find("#create_subprojct_tips").html(response.meta.msg);
                            }
                        });
                    });
                    createSubprojectLayer.find("#create_subprojct_cancel").click(closeCreateLayer);
                }
            }
            layer.open(dialogConf);
        }

        function getSubprojectLayerHtml() {
            if (createSubprojectlayerHtml == "") {
                var layerDiv = $("#create_subprojct_stub");
                layerDiv.css("display", "block");
                createSubprojectlayerHtml = layerDiv.html();
                layerDiv.css("display", "none");
            }
            return createSubprojectlayerHtml;
        }
    </script>
</head>
<body>

<%
    System.out.println("project.jsp->go");
    System.out.println("project.jsp->go->" + request.getAttribute("pageBean"));
    System.out.println("project.jsp->go->" + request.getAttribute("pageIndex"));
%>

<%--主页插桩--%>
<%@ include file="./stub.jsp" %>
<%--主页差异化内容--%>
<div class="content_stub_box">
    <div class="content_title_box" style="overflow: hidden;">
        <h2>项目管理</h2>
        <ul class="nav nav-pills">
            <li role="presentation" class="active"><a href="#">主项目</a></li>
            <li role="presentation"><a
                    href="<%= request.getServletContext().getContextPath() + "/main/listSubProjectServlet.do" %>">子项目</a>
            </li>
        </ul>
    </div>
    <hr/>
    <div class="table_top_func">
        <form class="form-inline"
              href="<%= request.getServletContext().getContextPath() + "/main/listProjectServlet.do" %>" method="get">
            <div class="form-group">
                <c:if test="${not empty key}">
                    <input type="text" class="form-control" id="key" name="key" placeholder="编号|名称"
                           value="${key}">
                </c:if>
                <c:if test="${empty key}">
                    <input type="text" class="form-control" id="key" name="key" placeholder="编号|名称">
                </c:if>
            </div>
            <button type="submit" class="btn btn-default">查询</button>
            <a id="create_project" href="javascript:void(0)" class="btn btn-primary">新建</a>
        </form>
    </div>
    <p class="table_name">项目信息列表</p>
    <table class="table table-bordered" style="overflow: auto;">
        <tr class="table_head_row">
            <td>编号</td>
            <td>名称</td>
            <td>业主单位</td>
            <td>创建时间</td>
            <td>子项目</td>
            <td>操作</td>
        </tr>
        <%--数据行--%>
        <c:forEach items="${pageBean.list}" var="p" varStatus="s">
            <c:if test="${s.count % 2 == 0}">
                <tr bgcolor="white" class="table_content_row">
            </c:if>
            <c:if test="${s.count % 2 != 0}">
                <tr bgcolor="#f5f5f5" class="table_content_row">
            </c:if>
            <td>${p.number}</td>
            <td>${p.name}</td>
            <td>${p.ownerName}</td>
            <td>${p.createDate}</td>
            <td>
                <p>
                    <a href="${pageContext.request.contextPath}/main/listSubProjectServlet.do?mainKey=${p.number}"
                       class="btn btn btn-info btn-sm">查看</a>
                    <button onclick="onCreateSubprojectClicked('${p.number}')"
                            type="button" class="btn btn btn-info btn-sm">新增
                    </button>
                </p>
            </td>
            <td>
                <button onclick="onProjectDeleteClicked('${p.number}')"
                        type="button" class="btn btn btn-danger btn-sm">删除
                </button>
            </td>
            </tr>
        </c:forEach>
    </table>
    <div class="nav_box">
        <%@ include file="main_paging_nav.jsp" %>
    </div>
</div>

<%--创建工程对话框，不直接显示，需通过layer.open展示--%>
<div id="create_projct_stub" style="display:none">
    <form id="create_projct_form" class="create_form">
        <div class="form_group">
            <label for="number"><span style="color: red">*&nbsp</span>编号：</label>
            <input class="form_input" type="text" id="number" placeholder="编号">
        </div>
        <div class="form_group">
            <label for="name"><span style="color: red">*&nbsp</span>名称：</label>
            <input class="form_input" type="text" id="name" placeholder="名称">
        </div>
        <div class="form_group">
            <label for="ownerName"><span style="color: red">*&nbsp</span>业主：</label>
            <input class="form_input" type="text" id="ownerName" placeholder="业主">
        </div>
        <div class="form_group">
            <label for="note"><span style="visibility: hidden">*&nbsp</span>备注：</label>
            <input class="form_input" type="text" id="note">
        </div>
    </form>
    <span id="create_tips" style="color:red;font-size: 12px;margin-left: 50px"></span>
    <button id="create_projct_cancel" type="button" class="create_layer_cancel btn btn-primary btn-sm">取消</button>
    <button id="create_projct_confirm" type="button" class="create_layer_confirm btn btn-primary btn-sm">确定</button>
</div>

<%--创建子工程对话框，不直接显示，需通过layer.open展示--%>
<div id="create_subprojct_stub" style="display:none">
    <form id="create_subproject_form" class="create_form">
        <div class="form_group">
            <label for="subproject_number"><span style="color: red">*&nbsp</span>编号：</label>
            <input class="form_input" type="text" id="subproject_number" placeholder="编号">
        </div>
        <div class="form_group">
            <label for="subproject_name"><span style="color: red">*&nbsp</span>名称：</label>
            <input class="form_input" type="text" id="subproject_name" placeholder="名称">
        </div>
        <div class="form_group">
            <label for="subproject_main_project"><span style="color: red">*&nbsp</span>主项目：</label>
            <input class="form_input" type="text" id="subproject_main_project" placeholder="主项目编号或名称">
        </div>
        <div class="form_group">
            <label for="subproject_note"><span style="visibility: hidden">*&nbsp</span>备注：</label>
            <input class="form_input" type="text" id="subproject_note">
        </div>
    </form>
    <span id="create_subproject_tips" style="color:red;font-size: 12px;margin-left: 50px"></span>
    <button id="create_subproject_cancel" type="button" class="create_layer_cancel btn btn-primary btn-sm">取消</button>
    <button id="create_subproject_confirm" type="button" class="create_layer_confirm btn btn-primary btn-sm">确定</button>
</div>
</body>
</html>
