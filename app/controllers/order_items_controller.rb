class OrderItemsController < ApplicationController
  def index
  end

  def show
  end

  def create
    
    unless current_user.orders.where(order_status_id: 1).empty?
      order = current_user.orders.where(order_status_id: 1).first
      
      
      
        
    else
      order = current_user.orders.create(order_status_id: 1, tax: 0.08)
    end
    
    item_sum = 0
    order.order_items.each { |order_item| item_sum += order_item.total_price }
    
    
    @item = Item.where(slug: params[:item_id]).first
    order_item = @item.order_items.create(order_item_params)
    order_item.item_id = @item.id
    order_item.unit_price = @item.price
    order_item.total_price = @item.price * order_item.quantity
    order_item.order_id = order.id
    
    if order_item.save
      update_order_total_price(order, order_item, item_sum)
      flash[:notice] = 'You just put this product into your shopping cart.'
      redirect_to  @item
    else
      flash[:alert] = order_item.errors.full_messages
      redirect_to  @item
    end
        
  end

  def edit
  end
  
  private
  
    def order_item_params
      params.require(:order_item).permit(:item_id, :quantity)
    end
    
    def update_order_total_price(order, item, item_sum)
      item_sum += item.total_price
      total_sum = item_sum + (item_sum * order.tax)
      
      order.update(order_total: total_sum)
    end
end
