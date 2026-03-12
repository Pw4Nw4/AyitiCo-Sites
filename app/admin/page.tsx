import { requireAuth } from "@/lib/session";
import { prisma } from "@/lib/prisma";
import { redirect } from "next/navigation";
import { Package, Users, DollarSign, ShoppingCart } from "lucide-react";

interface OrderWithUser {
  id: string;
  totalAmount: number;
  status: string;
  user: {
    email: string;
    firstName: string | null;
    lastName: string | null;
  };
}

interface LowStockProduct {
  id: string;
  name: string;
  category: string;
  stockQuantity: number;
}

export default async function AdminDashboard() {
  const session = await requireAuth();

  const user = await prisma.user.findUnique({
    where: { id: session.user.id },
  });

  if (!user?.isAdmin) {
    redirect("/");
  }

  const [totalOrders, totalUsers, totalRevenue, totalProducts] = await Promise.all([
    prisma.order.count(),
    prisma.user.count(),
    prisma.order.aggregate({
      _sum: { totalAmount: true },
      where: { paymentStatus: "paid" },
    }),
    prisma.product.count({ where: { isActive: true } }),
  ]);

  const recentOrders = await prisma.order.findMany({
    take: 10,
    orderBy: { createdAt: "desc" },
    include: {
      user: {
        select: { email: true, firstName: true, lastName: true },
      },
    },
  }) as OrderWithUser[];

  const lowStockProducts = await prisma.product.findMany({
    where: {
      stockQuantity: { lte: 10 },
      isActive: true,
    },
    take: 10,
    orderBy: { stockQuantity: "asc" },
    select: {
      id: true,
      name: true,
      category: true,
      stockQuantity: true,
    },
  }) as LowStockProduct[];

  return (
    <div className="min-h-screen bg-slate-900">
      <div className="container mx-auto px-4 py-8">
        <h1 className="text-3xl font-bold text-white mb-8">Admin Dashboard</h1>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
          <div className="bg-slate-800/50 rounded-xl p-6 border border-slate-700">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-slate-400 text-sm">Total Orders</p>
                <p className="text-3xl font-bold text-white mt-2">{totalOrders}</p>
              </div>
              <Package className="w-12 h-12 text-cyan-500" />
            </div>
          </div>

          <div className="bg-slate-800/50 rounded-xl p-6 border border-slate-700">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-slate-400 text-sm">Total Users</p>
                <p className="text-3xl font-bold text-white mt-2">{totalUsers}</p>
              </div>
              <Users className="w-12 h-12 text-green-500" />
            </div>
          </div>

          <div className="bg-slate-800/50 rounded-xl p-6 border border-slate-700">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-slate-400 text-sm">Total Revenue</p>
                <p className="text-3xl font-bold text-white mt-2">
                  ${Number(totalRevenue._sum.totalAmount || 0).toFixed(2)}
                </p>
              </div>
              <DollarSign className="w-12 h-12 text-yellow-500" />
            </div>
          </div>

          <div className="bg-slate-800/50 rounded-xl p-6 border border-slate-700">
            <div className="flex items-center justify-between">
              <div>
                <p className="text-slate-400 text-sm">Active Products</p>
                <p className="text-3xl font-bold text-white mt-2">{totalProducts}</p>
              </div>
              <ShoppingCart className="w-12 h-12 text-purple-500" />
            </div>
          </div>
        </div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
          <div className="bg-slate-800/50 rounded-xl p-6 border border-slate-700">
            <h2 className="text-xl font-bold text-white mb-4">Recent Orders</h2>
            <div className="space-y-3">
              {recentOrders.map((order: OrderWithUser) => (
                <div key={order.id} className="flex items-center justify-between p-3 bg-slate-700/50 rounded-lg">
                  <div>
                    <p className="text-white font-medium">
                      {order.user.firstName} {order.user.lastName}
                    </p>
                    <p className="text-slate-400 text-sm">{order.user.email}</p>
                  </div>
                  <div className="text-right">
                    <p className="text-cyan-400 font-bold">${Number(order.totalAmount).toFixed(2)}</p>
                    <p className="text-slate-400 text-sm">{order.status}</p>
                  </div>
                </div>
              ))}
            </div>
          </div>

          <div className="bg-slate-800/50 rounded-xl p-6 border border-slate-700">
            <h2 className="text-xl font-bold text-white mb-4">Low Stock Alert</h2>
            <div className="space-y-3">
              {lowStockProducts.map((product: LowStockProduct) => (
                <div key={product.id} className="flex items-center justify-between p-3 bg-slate-700/50 rounded-lg">
                  <div>
                    <p className="text-white font-medium">{product.name}</p>
                    <p className="text-slate-400 text-sm">{product.category}</p>
                  </div>
                  <div className="text-right">
                    <p className={`font-bold ${product.stockQuantity === 0 ? "text-red-400" : "text-yellow-400"}`}>
                      {product.stockQuantity} left
                    </p>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
