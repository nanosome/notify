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
package nanosome.notify.field.impl {
	import nanosome.notify.field.IField;
	import nanosome.notify.field.IFieldObserver;
	import nanosome.util.list.List;
	import nanosome.util.list.ListNode;
	import nanosome.util.pool.poolFor;
	
	/**
	 * @author mh
	 */
	public class ObserverList extends List {
		
		private var _first: ObserverListNode;
		private var _next: ObserverListNode;
		public function ObserverList() {
			super( poolFor( ObserverListNode ) );
		}
		
		override protected function get first(): ListNode {
			return _first;
		}
		
		override protected function set first(node : ListNode) : void {
			_first = ObserverListNode( node );
		}
		
		override protected function get next() : ListNode {
			return _next;
		}
		
		override protected function set next( node: ListNode ) : void {
			_next = ObserverListNode( node );
		}
		
		public function notifyPropertyChange( mo: IField, oldValue: *, newValue: * ): void {
			var current: ObserverListNode = _first;
			var observer: IFieldObserver;
			
			startIterate();
			while( current ) {
				_next = current.nextObserver;
				observer = current.strongObserver;
				if( observer ) {
					observer.onFieldChange( mo, oldValue, newValue );
				} else {
					observer = current.weak;
					if( observer ) {
						observer.onFieldChange( mo, oldValue, newValue );
					} else {
						removeNode( current );
					}
				}
				current = _next;
			}
			stopIterate();
		}
	}
}