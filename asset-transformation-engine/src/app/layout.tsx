import type { Metadata } from "next"; import "./globals.css"; import { AppShell } from "@/components/app-shell";
export const metadata:Metadata={title:"Asset Transformation Engine",description:"Auditable biotech opportunity and company-formation decision engine"};
export default function RootLayout({children}:{children:React.ReactNode}){return <html lang="en"><body><AppShell>{children}</AppShell></body></html>}
