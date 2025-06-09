# 注意！！！

1. 微信小程序开发时，每次新增组件，都需要停止模拟器然后重启才能显示新的控件，不然会抛出异常没找到这个控件





# 基础安装

**创建项目**

下载[基于uview的uniapp的空白工程](https://v1.uviewui.com/components/resource.html)

使用HbuilderX导入项目



**配置网络请求**

[uView网络配置](https://v1.uviewui.com/js/http.html)

1. 创建一个common目录，并新建文件为`http.interceptor.js`

2. copy下面的文件，并修改其中的一些配置（token、状态码等）

   ```js
   // 这里的vm，就是我们在vue文件里面的this，所以我们能在这里获取vuex的变量，比如存放在里面的token变量
   const install = (Vue, vm) => {
   	// 此为自定义配置参数，具体参数见上方说明
   	Vue.prototype.$u.http.setConfig({
   		baseUrl: 'https://www.coderymy.cn/wechat-mp', // 请求的本域名
   		// method: 'POST',
   		// 设置为json，返回后会对数据进行一次JSON.parse()
   		dataType: 'json',
   		showLoading: true, // 是否显示请求中的loading
   		loadingText: '请求中...', // 请求loading中的文字提示
   		loadingTime: 800, // 在此时间内，请求还没回来的话，就显示加载中动画，单位ms
   		originalData: false, // 是否在拦截器中返回服务端的原始数据
   		loadingMask: true, // 展示loading的时候，是否给一个透明的蒙层，防止触摸穿透
   		// 配置请求头信息
   		// header: {
   		// 	'content-type': 'application/json;charset=UTF-8'
   		// },
   	});
   
   	// 请求拦截，配置Token等参数
   	Vue.prototype.$u.http.interceptor.request = (config) => {
   		// 引用token
   		// 方式一，存放在vuex的token，假设使用了uView封装的vuex方式
   		// 见：https://uviewui.com/components/globalVariable.html
   		// config.header.token = vm.token;
   
   		// 方式二，如果没有使用uView封装的vuex方法，那么需要使用$store.state获取
   		// config.header.token = vm.$store.state.token;
   
   		// 方式三，如果token放在了globalData，通过getApp().globalData获取
   		// config.header.token = getApp().globalData.username;
   
   		// 方式四，如果token放在了Storage本地存储中，拦截是每次请求都执行的
   		// 所以哪怕您重新登录修改了Storage，下一次的请求将会是最新值
   		// const token = uni.getStorageSync('token');
   		// config.header.token = token;
   		config.header.Token = 'xxxxxx';
   
   		// 可以对某个url进行特别处理，此url参数为this.$u.get(url)中的url值
   		if (config.url == '/user/login') config.header.noToken = true;
   		// 最后需要将config进行return
   		return config;
   		// 如果return一个false值，则会取消本次请求
   		// if(config.url == '/user/rest') return false; // 取消某次请求
   	}
   
   	// 响应拦截，判断状态码是否通过
   	Vue.prototype.$u.http.interceptor.response = (res) => {
   		//以返回信息为{"code":1,"msg":"成功","data":"success","stime":1656485004373,"traceId":"d0146444cbf842809121b967eb001c5c"}这种类型为例
   		//从res中获取到具体需要用到的数据
   		const {code,data,msg} =res
   		if (code == 1) {
   			// 这里对data进行返回，将会在this.$u.post(url).then(res => {})的then回调中的res得到
   			// 如果配置了originalData为true，则返回的信息包含整个Http请求的结果信息需要留意这里的返回值可能不太一样
   			return data;
   		} else if (code == 4001) {
   			// 假设201为token失效，这里跳转登录
   			vm.$u.toast('验证失败，请重新登录');
   			setTimeout(() => {
   				// 此为uView的方法，详见路由相关文档
   				vm.$u.route('/pages/user/login')
   			}, 1500)
   			return false;
   		} else {
   			// 如果返回false，则会调用Promise的reject回调，
   			// 并将进入this.$u.post(url).then().catch(res=>{})的catch回调中，res为服务端的返回值
   			return false;
   		}
   	}
   }
   
   export default {
   	install
   }
   
   ```

3. 在main.js中引入

   ```js
   // http拦截器，此为需要加入的内容，如果不是写在common目录，请自行修改引入路径
   import httpInterceptor from '@/common/http.interceptor.js'
   // 这里需要写在最后，是为了等Vue创建对象完成，引入"app"对象(也即页面的"this"实例)
   Vue.use(httpInterceptor, app)
   ```

4. 在index.vue中测试

   ```
   <script>
   	export default {
   		data() {
   			return {}
   		},
   		onLoad() {
   			this.$u.get("/health/checkHealth").then(res => {
   				console.log(res)
   			}).catch(e => {
   				console.log(e)
   			})
   		},
   		methods: {
   
   		}
   	}
   </script>
   ```

同步请求和异步请求：

[如何使用await进行同步操作](https://v1.uviewui.com/js/http.html)

`this.$u.get`

注意点：await必须只能使用在async定义的方法中。这样就可以完成同步请求。只有等待请求结果执行完了才能该方法下面的代码

```
export default {
	// 可以放心在生命周期前加上async，不会导致问题
	async onLoad() {
		let ret = await this.$u.post('/user/login');
		// 此处在函数体外写了async，并且使用了await等待返回，所以可以打印ret结果
		// 意味着这里的console.log是等待了几十毫秒请求返回后才执行的
		console.log(ret);
	}
}
```



**统一管理API**



1. common中新建一个`http.api.js`

   ```js
   const install = (Vue, vm) => {	
     //这个的目的是定义API属性是{}
   	vm.$u.api={}
   	//认证相关的
   	vm.$u.api.authLogin=params =>vm.$u.post('/user/login',params)//登陆
   	//基础接口
   	vm.$u.api.chechHealth=()=>vm.$u.get('/health/checkHealth')//健康检查
   	//卡片盒接口
   	vm.$u.api.listCardBox=cardBox=>vm.$u.get('/cardBox/list',cardBox)//获取卡片盒列表
   	//卡片相关的接口
   	// 使用的时候直接使用this.$u.api.xxx(params)即可调用到后端
   }
   
   export default {
   	install
   }
   ```

2. 在main.js中挂载并放在拦截器后面

   ```js
   // http接口API集中管理引入部分
   import httpApi from '@/common/http.api.js'
   Vue.use(httpApi, app)
   ```

3. 在页面中直接使用

   ```
   sasync onLoad(){
   	let res=this.$u.api.authLogin(params)
   	console.log(res)
   }
   ```

   





**使用vuex**

1. 创建目录store并新建文件`index.js`

   ```js
   import Vue from 'vue'
   import Vuex from 'vuex'
   Vue.use(Vuex)
   
   let lifeData = {};
   
   try{
   	// 尝试获取本地是否存在lifeData变量，第一次启动APP时是不存在的
   	lifeData = uni.getStorageSync('lifeData');
   }catch(e){
   	
   }
   
   // 需要永久存储，且下次APP启动需要取出的，在state中的变量名
   let saveStateKeys = ['vuex_user', 'vuex_token'];
   
   // 保存变量到本地存储中
   const saveLifeData = function(key, value){
   	// 判断变量名是否在需要存储的数组中
   	if(saveStateKeys.indexOf(key) != -1) {
   		// 获取本地存储的lifeData对象，将变量添加到对象中
   		let tmp = uni.getStorageSync('lifeData');
   		// 第一次打开APP，不存在lifeData变量，故放一个{}空对象
   		tmp = tmp ? tmp : {};
   		tmp[key] = value;
   		// 执行这一步后，所有需要存储的变量，都挂载在本地的lifeData对象中
   		uni.setStorageSync('lifeData', tmp);
   	}
   }
   const store = new Vuex.Store({
   	// 下面这些值仅为示例，使用过程中请删除
   	state: {
   		// 如果上面从本地获取的lifeData对象下有对应的属性，就赋值给state中对应的变量
   		// 加上vuex_前缀，是防止变量名冲突，也让人一目了然
   		vuex_user: lifeData.vuex_user ? lifeData.vuex_user : {name: '明月'},
   		vuex_token: lifeData.vuex_token ? lifeData.vuex_token : '',
   		// 如果vuex_version无需保存到本地永久存储，无需lifeData.vuex_version方式
   		vuex_version: '1.0.1',
   	},
   	mutations: {
   		$uStore(state, payload) {
   			// 判断是否多层级调用，state中为对象存在的情况，诸如user.info.score = 1
   			let nameArr = payload.name.split('.');
   			let saveKey = '';
   			let len = nameArr.length;
   			if(nameArr.length >= 2) {
   				let obj = state[nameArr[0]];
   				for(let i = 1; i < len - 1; i ++) {
   					obj = obj[nameArr[i]];
   				}
   				obj[nameArr[len - 1]] = payload.value;
   				saveKey = nameArr[0];
   			} else {
   				// 单层级变量，在state就是一个普通变量的情况
   				state[payload.name] = payload.value;
   				saveKey = payload.name;
   			}
   			// 保存变量到本地，见顶部函数定义
   			saveLifeData(saveKey, state[saveKey])
   		}
   	}
   })
   
   export default store
   ```

   修改`saveStateKeys`来让需要永久保存的数据进行保存

2. 在store中创建`$u.mixin.js`的文件。目的就是将vuex绑定到vue的实例vm中，这样就可以直接使用this访问

   ```js
   // $u.mixin.js
   
   import { mapState } from 'vuex'
   import store from "@/store"
   
   // 尝试将用户在根目录中的store/index.js的vuex的state变量，全部加载到全局变量中
   let $uStoreKey = [];
   try{
   	$uStoreKey = store.state ? Object.keys(store.state) : [];
   }catch(e){
   	
   }
   
   module.exports = {
   	created() {
   		// 将vuex方法挂在到$u中
   		// 使用方法为：如果要修改vuex的state中的user.name变量为"史诗" => this.$u.vuex('user.name', '史诗')
   		// 如果要修改vuex的state的version变量为1.0.1 => this.$u.vuex('version', '1.0.1')
   		this.$u.vuex = (name, value) => {
   			this.$store.commit('$uStore', {
   				name,value
   			})
   		}
   	},
   	computed: {
   		// 将vuex的state中的所有变量，解构到全局混入的mixin中
   		...mapState($uStoreKey)
   	}
   }
   ```

3. 将两个文件绑定到`main.js`

   ```js
   import Vue from 'vue'
   import App from './App'
   Vue.config.productionTip = false
   App.mpType = 'app'
   let vuexStore = require("@/store/$u.mixin.js");
   Vue.mixin(vuexStore);
   // 引入全局uView
   import uView from 'uview-ui'
   import store from '@/store';
   Vue.use(uView);
   const app = new Vue({
   	store,
   	...App
   })
   // http拦截器，此为需要加入的内容，如果不是写在common目录，请自行修改引入路径
   import httpInterceptor from '@/common/http.interceptor.js'
   // 这里需要写在最后，是为了等Vue创建对象完成，引入"app"对象(也即页面的"this"实例)
   Vue.use(httpInterceptor, app)
   // http接口API集中管理引入部分
   import httpApi from '@/common/http.api.js'
   Vue.use(httpApi, app)
   app.$mount()
   
   ```

4. 之后就可以直接使用`this.keyName`获取了。在模版中直接使用{{keyName}}就可以获取到

   默认定义了两个存放内存中的变量`user`和`token`如果需要再加需要在下面的两个地方增加key

   ![](https://coderymy-image.oss-cn-beijing.aliyuncs.com/uPic/iMwynL.png)添加：

   + 在store/index.js中的state中设置一个变量名，值可以给默认或者直接给''空
   + 然后在需要增加的地方调用`this.$u.vuex(key,value)`即可完成添加
   + 获取的时候还是可以直接使用`this.key`就可以获取出来
   + 如果想要在刷新之后仍然有，就需要像`vuex_user`一样设置一下

**路由守卫**

也就是一些路由规则进行跳转之类。比如访问某个页面发现没有登陆就跳到登陆页面

[大型项目一般使用这个](https://hhyang.cn/v2/)



自定义跳转工具

1. 创建`utils.js`的工具

   ```
   const install = (Vue, vm) => {
   	// 是否登录
   	const isLogin=()=>{
   		const token=vm.vuex_token
   		// 没有token，跳转登录页面
   		if(!token){
   			// 回源跳转，拿到当前页
   			let currentRoute;
   			if(getCurrentPages().pop().goodsId){
   				// 如果url带参数，加上参数
   				currentRoute=`/${getCurrentPages().pop().route}?id=${getCurrentPages().pop().goodsId}`
   			}else{
   				currentRoute=`/${getCurrentPages().pop().route}`
   			}
   			uni.setStorageSync("currentRoute",currentRoute)
   			
   			uni.showToast({
   				title:"请先登入",
   				icon:"error",
   				mask:true
   			})
   			setTimeout(()=>{
   				// 跳转登录页
   				vm.$u.route({
   					url:'/pages/auth/login'
   				})
   			},1500)
   			return false
   		}
   		return true
   	}
   	// 更新用户信息
   	const setUserInfo= async()=>{
   		// 更新vuex用户信息
   		const userInfo = await vm.$u.api.getUserInfo()
   		vm.$u.vuex('vuex_user',userInfo)
   	}
   	vm.$u.utils={
   		isLogin,
   		setUserInfo
   	}
   }
   
   export default {
   	install
   }
   ```

2. 绑定到`main.js`中

   ```
   
   // 引入自定义的一些工具API
   import utils from '@/common/utils.js'
   Vue.use(utils, app)
   ```

3. 在哪个地方需要使用的就可以直接调用`this.$u.utils.isLogin()`就可以去校验是否登陆，如果咩有登陆就会跳转到登陆页面

   使用`if(this.$u.utils.isLogin()) return`如果出现false就不会执行下面的代码了。因为这个跳转是异步的操作







**使用`mp-html`进行markdown解析**

修改样式的一些基本信息之后，运行下面的代码将其替换掉。也可以运行文件夹下自定义的`buildAndPublish.sh`文件一键打包替换

```
npm run build:uni-app

cp -r dist/uni-app/components/mp-html ../maya-mp/components
cp -r dist/uni-app/static/app-plus ../maya-mp/static

```







# 语法

1. class='u-text-center'可以将文本进行居中显示

   基于uview的[内置样式](https://v1.uviewui.com/components/common.html)

2. 点击跳转，外层包裹`<navigator>`指定跳转的连接即可

3. 字体

   + Font-weight：粗细
   + font-size：大小
   + color：#888显得字体不是那么黑

4. 数组的数据追加

   `this.list=[...this.list,...res.list]`

5. 滑动到底部的时候

   触发调用方法`onReachBottom()`

6. 使用骨架屏

   1. 引用组件
   2. 在api请求之前定义true，请求之后false
   3. 在需要显示骨架的地方class增加具体的参数
   4. 循环的时候需要先定义一些默认的参数

7. 跳转页面JS操作

   注意点：1. 不能跳转到tarbar上的页面。2. 跳转路径不能是`/pages/xxx/xx`而应该是`pages/xxx/xxx`

   ```
   this.$u.route({
   	type:"",
   	url:""
   })
   ```

   [uview跳转文档](https://v1.uviewui.com/js/route.html)

   如果是需要跳转到tarber上的页面，可以使用`uni.switchTab({}) `





