import {
  loadFixture,
  time,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { ethers } from "hardhat";
import hre from "hardhat";
import { expect } from "chai";

describe("DutchAuction", () => {
  const deployNft = async () => {
    const nftFactory = await hre.ethers.getContractFactory("AuctionNft");

    const nft = await nftFactory.deploy();

    return { nft };
  };

  const deployDutchAuction = async () => {
    const { nft } = await loadFixture(deployNft);

    const ductionActionFactory = await hre.ethers.getContractFactory(
      "DutchAuction"
    );

    const [owner, buyer] = await hre.ethers.getSigners();

    const NFT_ID = 0;
    const ONE_WEEK_IN_SECS = 7 * 24 * 60 * 60;
    const DISCOUNT_RATE = Math.floor(0.1 / (24 * 60 * 60)); //10% per day
    const price = ethers.parseEther("10");

    const endDate = (await time.latest()) + ONE_WEEK_IN_SECS;

    const dutchAuction = await ductionActionFactory.deploy(nft, NFT_ID);

    return { dutchAuction, owner, endDate, nft, price, buyer, DISCOUNT_RATE };
  };

  describe("Deployment", () => {
    it("should deploy the auction with correct arguments", async () => {
      const { dutchAuction, owner, endDate, nft } = await loadFixture(
        deployDutchAuction
      );

      expect(await dutchAuction.NFT()).to.equal(nft);
      expect(await dutchAuction.SELLER()).to.equal(owner);
    });
  });

  describe("StartAuction", () => {
    it("should start auction", async () => {
      const { dutchAuction, price, nft, owner, DISCOUNT_RATE } =
        await loadFixture(deployDutchAuction);

      await nft.mintNFT(owner, "", 0);
      const dutchAddress = await dutchAuction.getAddress();

      await nft.approve(dutchAddress, 0);

      await dutchAuction.startAuction(price, DISCOUNT_RATE);
      const nftOwner = await nft.ownerOf(0);

      expect(await dutchAuction.auctionOpen()).to.equal(true);
      expect(nftOwner).to.equal(dutchAddress);
    });

    it("should fail when price is 0", async () => {
      const { dutchAuction, nft, owner, DISCOUNT_RATE } = await loadFixture(
        deployDutchAuction
      );

      await nft.mintNFT(owner, "", 0);

      await nft.approve(dutchAuction, 0);

      await expect(
        dutchAuction.startAuction(0, DISCOUNT_RATE)
      ).to.be.revertedWith("price cant be 0");
    });
  });

  describe("buyNft", () => {
    it("should send NFT to buyer", async () => {
      const { dutchAuction, nft, owner, buyer, price, DISCOUNT_RATE } =
        await loadFixture(deployDutchAuction);

      await nft.mintNFT(owner, "", 0);
      const dutchAddress = await dutchAuction.getAddress();

      await nft.approve(dutchAddress, 0);

      await dutchAuction.startAuction(price, DISCOUNT_RATE);

      const amount = ethers.parseEther("12");
      await dutchAuction.connect(buyer).buyNft(amount);

      expect(await nft.ownerOf(1)).to.equal(buyer);
    });
  });
});
