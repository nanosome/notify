//  
// Licensed to the Apache Software Foundation (ASF) under one
// or more contributor license agreements.  See the NOTICE file
// distributed with this work for additional information
// regarding copyright ownership.  The ASF licenses this file
// to you under the Apache License, Version 2.0 (the
// "License"); you may not use this file except in compliance
// with the License.  You may obtain a copy of the License at
// 
// http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License. 
// 
package nanosome.notify.observe {
	
	
	import nanosome.util.list.ListNode;
	
	/**
	 * <code>PropertyBroadcasterNode</code> is a implementation for internal use
	 * that provides a easy way to implement broadcasting for easy implementations
	 * of the <code>IPropertyObservable</code> interface.
	 * 
	 * <p>This instance is internal in order to be able to make it final (performance)
	 * and to have the properties as internal variables.</p>
	 * 
	 * @author Martin Heidegger mh@leichtgewicht.at
	 * @version 1.0
	 * @see IPropertyObservable
	 */
	internal final class PropertyBroadcasterNode extends ListNode {
		
		public function PropertyBroadcasterNode() {
			super();
		}
		
		/**
		 * Observer matching to this node.
		 */
		internal var _strong: IPropertyObserver;
		
		/**
		 * Next node to be executed
		 */
		internal var _next: PropertyBroadcasterNode;
		
		/**
		 * @inheritDoc
		 */
		override public function set next( node: ListNode ): void {
			super.next = node;
			_next = PropertyBroadcasterNode( node );
		}
		
		/**
		 * @inheritDoc
		 */
		override public function set strong( content: * ): void {
			_strong = IPropertyObserver( content );
		}
		
		override public function get strong(): * {
			return _strong;
		}
	}
}
