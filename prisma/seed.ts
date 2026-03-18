import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcrypt';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Seeding database...');

  // Create admin user
  const hashedPassword = await bcrypt.hash('Admin@123', 12);
  const admin = await prisma.user.upsert({
    where: { email: 'admin@ayitico.com' },
    update: {},
    create: {
      email: 'admin@ayitico.com',
      password: hashedPassword,
      firstName: 'Admin',
      lastName: 'User',
      isAdmin: true,
      isActive: true,
      emailVerified: new Date(),
      country: 'Haiti',
    },
  });
  console.log('✓ Admin user created:', admin.email);

  // Create categories
  const categories = [
    { name: 'Electronics', description: 'Electronic devices and accessories', image: '/categories/electronics.jpg' },
    { name: 'Fashion', description: 'Clothing and accessories', image: '/categories/fashion.jpg' },
    { name: 'Home & Garden', description: 'Home decor and garden supplies', image: '/categories/home.jpg' },
    { name: 'Food & Beverages', description: 'Local food and drinks', image: '/categories/food.jpg' },
    { name: 'Art & Crafts', description: 'Handmade art and crafts', image: '/categories/art.jpg' },
  ];

  for (const cat of categories) {
    await prisma.category.upsert({
      where: { name: cat.name },
      update: {},
      create: cat,
    });
  }
  console.log('✓ Categories created');

  // Create sample products
  const products = [
    {
      name: 'Haitian Coffee - Premium Blend',
      price: 15.99,
      description: 'Premium Haitian coffee beans, freshly roasted',
      category: 'Food & Beverages',
      stockQuantity: 50,
      images: ['/products/coffee.jpg'],
      isActive: true,
    },
    {
      name: 'Traditional Haitian Dress',
      price: 89.99,
      description: 'Beautiful traditional Haitian dress, handmade',
      category: 'Fashion',
      stockQuantity: 20,
      images: ['/products/dress.jpg'],
      isActive: true,
    },
    {
      name: 'Haitian Art Painting',
      price: 199.99,
      description: 'Original Haitian art painting by local artist',
      category: 'Art & Crafts',
      stockQuantity: 5,
      images: ['/products/painting.jpg'],
      isActive: true,
    },
  ];

  for (const product of products) {
    await prisma.product.create({
      data: product,
    });
  }
  console.log('✓ Sample products created');

  console.log('✅ Seeding completed!');
}

main()
  .catch((e) => {
    console.error('❌ Seeding failed:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
